variable "resource_group_name" {}
variable "db_name" {}
variable "admin_user_name" {}
variable "admin_password" {}
variable "user_name" {}
variable "user_can_create_db" {}
variable "pg_server_name" {}
variable "server_fqdn" {}
variable "replication" {}

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

resource "postgresql_grant" "grant_public_schema" {
  database    = postgresql_database.db.name
  role        = postgresql_role.user.name
  schema      = "public"
  object_type = "schema"

  privileges = ["USAGE", "CREATE"]
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

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
  }
}

