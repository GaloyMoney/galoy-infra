variable "gcp_project" {}
variable "db_name" {}
variable "admin_user_name" {}
variable "user_name" {}
variable "pg_instance_connection_name" {}

output "user" {
  value = postgresql_role.user.name
}

output "password" {
  value = random_password.user.result
}

resource "random_password" "user" {
  length  = 20
  special = false
}

resource "postgresql_role" "user" {
  name     = var.user_name
  password = random_password.user.result
  login    = true
}

resource "postgresql_database" "db" {
  name       = var.db_name
  owner      = var.admin_user_name
  template   = "template0"
  lc_collate = "en_US.UTF8"
}

resource "postgresql_grant" "revoke_public" {
  database    = postgresql_database.db.name
  role        = "public"
  object_type = "database"
  privileges  = []
}

resource "postgresql_grant" "grant_all" {
  database    = postgresql_database.db.name
  role        = postgresql_role.user.name
  object_type = "database"

  # Basically "ALL" but then tf will redeploy
  privileges = ["CONNECT", "CREATE", "TEMPORARY"]

  depends_on = [
    postgresql_grant.revoke_public,
  ]
}

resource "random_password" "big_query" {
  length  = 20
  special = false
}

resource "postgresql_role" "big_query" {
  name     = "${var.db_name}-big-query"
  password = random_password.big_query.result
  login    = true
}

resource "postgresql_grant" "big_query_connect" {
  database    = postgresql_database.db.name
  role        = postgresql_role.big_query.name
  object_type = "database"

  privileges = ["CONNECT"]

  depends_on = [
    google_bigquery_connection.db
    postgresql_grant.grant_all
  ]
}
resource "postgresql_grant" "big_query_select" {
  database    = postgresql_database.db.name
  role        = postgresql_role.big_query.name
  object_type = "table"
  schema      = "public"

  privileges = ["SELECT"]

  depends_on = [
    google_bigquery_connection.db
    postgresql_grant.big_query_connect
  ]
}

resource "google_bigquery_connection" "db" {
  project       = var.gcp_project
  friendly_name = "${var.db_name}-connection"
  description   = "Connection to ${var.db_name} database"
  location      = "US"
  cloud_sql {
    instance_id = var.pg_instance_connection_name
    database    = postgresql_database.db.name
    type        = "POSTGRES"
    credential {
      username = postgresql_role.big_query.name
      password = random_password.big_query.result
    }
  }
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
  }
}
