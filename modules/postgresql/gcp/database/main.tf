variable "gcp_project" {}
variable "db_name" {}
variable "admin_user_name" {}
variable "user_name" {}
variable "user_can_create_db" {}
variable "pg_instance_connection_name" {}
variable "replication" {}
variable "upgradable" {}
variable "connection_users" {
  type = list(string)
}
variable "big_query_connection_location" {}

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
  name            = var.user_name
  password        = random_password.user.result
  login           = true
  create_database = var.user_can_create_db
}

output "replicator_password" {
  value = var.replication ? random_password.replicator[0].result : null
}

resource "random_password" "replicator" {
  count   = var.replication ? 1 : 0
  length  = 20
  special = false
}

resource "postgresql_role" "replicator" {
  count       = var.replication ? 1 : 0
  name        = "${var.db_name}-replicator"
  password    = random_password.replicator[0].result
  login       = true
  replication = true
}

resource "postgresql_database" "db" {
  name       = var.db_name
  owner      = var.admin_user_name
  template   = "template0"
  lc_collate = "en_US.UTF8"
}

resource "postgresql_extension" "pglogical" {
  count      = var.upgradable ? 1 : 0
  name       = "pglogical"
  database   = var.db_name
  depends_on = [postgresql_database.db]
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
    postgresql_grant.revoke_public
  ]
}

resource "postgresql_grant" "grant_connect_replicator" {
  count       = var.replication ? 1 : 0
  database    = postgresql_database.db.name
  role        = postgresql_role.replicator[0].name
  object_type = "database"

  privileges = ["CONNECT"]

  depends_on = [
    postgresql_grant.revoke_public
  ]
}

resource "postgresql_grant" "grant_select_replicator" {
  count       = var.replication ? 1 : 0
  database    = postgresql_database.db.name
  role        = postgresql_role.replicator[0].name
  schema      = "public"
  object_type = "table"

  privileges = ["SELECT"]
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
    google_bigquery_connection.db,
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
    google_bigquery_connection.db,
    postgresql_grant.big_query_connect
  ]
}

resource "google_bigquery_connection" "db" {
  project       = var.gcp_project
  friendly_name = "${var.db_name}-connection"
  description   = "Connection to ${var.db_name} database"
  location      = var.big_query_connection_location

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

resource "google_bigquery_connection_iam_member" "user" {
  for_each      = toset(var.connection_users)
  project       = var.gcp_project
  location      = google_bigquery_connection.db.location
  connection_id = google_bigquery_connection.db.connection_id
  role          = "roles/bigquery.connectionUser"
  member        = each.value
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.22.0"
    }
  }
}
