variable "db_name" {}
variable "admin_user_name" {}
variable "user_name" {}
variable "readonly_users" {
  description = "List of read-only user suffixes to create. Each entry creates a role named '<db_name>-<suffix>' with CONNECT/USAGE/SELECT grants."
  type        = list(string)
  default     = []
}
output "user" {
  value = postgresql_role.user.name
}

output "password" {
  value = random_password.user.result
}

output "readonly_users" {
  value = {
    for name in var.readonly_users : name => {
      user     = postgresql_role.readonly_user[name].name
      password = random_password.readonly_user[name].result
    }
  }
  sensitive = true
}

resource "random_password" "user" {
  length  = 20
  special = false
}

resource "postgresql_role" "user" {
  name            = var.user_name
  password        = random_password.user.result
  login           = true
  create_database = false
}

resource "random_password" "readonly_user" {
  for_each = toset(var.readonly_users)
  length   = 20
  special  = false
}

resource "postgresql_role" "readonly_user" {
  for_each = toset(var.readonly_users)
  name     = "${var.db_name}-${each.value}"
  password = random_password.readonly_user[each.key].result
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

resource "postgresql_grant" "grant_connect_readonly_user" {
  for_each    = toset(var.readonly_users)
  database    = postgresql_database.db.name
  role        = postgresql_role.readonly_user[each.key].name
  object_type = "database"

  privileges = ["CONNECT"]

  depends_on = [
    postgresql_grant.revoke_public
  ]
}

resource "postgresql_grant" "grant_usage_readonly_user" {
  for_each    = toset(var.readonly_users)
  database    = postgresql_database.db.name
  role        = postgresql_role.readonly_user[each.key].name
  schema      = "public"
  object_type = "schema"

  privileges = ["USAGE"]

  depends_on = [
    postgresql_grant.grant_connect_readonly_user
  ]
}

resource "postgresql_grant" "grant_select_readonly_user" {
  for_each    = toset(var.readonly_users)
  database    = postgresql_database.db.name
  role        = postgresql_role.readonly_user[each.key].name
  schema      = "public"
  object_type = "table"

  privileges = ["SELECT"]

  depends_on = [
    postgresql_grant.grant_usage_readonly_user
  ]
}

# `postgresql_grant` above is a one-time snapshot: SELECT is granted only
# on tables that exist at apply time. Application schemas are created by
# SQL migrations that run *after* Terraform (as `postgresql_role.user`),
# so without this any later-added table is invisible to the readonly
# role — `GRANT SELECT ON ALL TABLES` includes nothing future.
#
# `postgresql_default_privileges` installs an `ALTER DEFAULT PRIVILEGES`
# rule scoped to objects created by the migrations-running role, so any
# table that role creates in `public` auto-grants SELECT to the readonly
# user at creation time. Covers all past, present, and future tables
# when combined with the grant above.
resource "postgresql_default_privileges" "readonly_user_select_future_tables" {
  for_each    = toset(var.readonly_users)
  database    = postgresql_database.db.name
  role        = postgresql_role.readonly_user[each.key].name
  owner       = postgresql_role.user.name
  schema      = "public"
  object_type = "table"

  privileges = ["SELECT"]

  depends_on = [
    postgresql_grant.grant_usage_readonly_user,
  ]
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
  }
}
