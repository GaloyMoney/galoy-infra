variable "prefix" {}
variable "owner" {}

locals {
  prefix = var.prefix
  owner  = var.owner
}

resource "random_password" "sql_password" {
  length  = 20
  special = false
}

resource "postgresql_role" "user" {
  name     = "${local.prefix}_user"
  login    = true
  password = random_password.sql_password.result
}

resource "postgresql_database" "db" {
  name       = local.prefix
  owner      = var.owner
  template   = "template0"
  lc_collate = "DEFAULT"
}

output "password" {
  value     = random_password.sql_password.result
  sensitive = true
}

output "username" {
  value = postgresql_role.user.name
}

resource "postgresql_grant" "revoke_public" {
  database    = postgresql_database.db.name
  role        = "public"
  object_type = "database"
  privileges  = []
}

resource "postgresql_grant" "grant_all_dealer" {
  database    = postgresql_database.db.name
  role        = postgresql_role.user.name
  object_type = "database"
  privileges  = ["ALL"]

  depends_on = [
    postgresql_grant.revoke_public,
  ]
}
