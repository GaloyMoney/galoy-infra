variable "region" {}
variable "database_port" {}
variable "instance_name" {}
variable "destroyable" {}
variable "tier" {}
variable "highly_available" {}
variable "enable_detailed_logging" {}
variable "replication" {}
variable "destination_database_version" {}
variable "migration_databases" {}
variable "max_connections" {}
variable "gcp_project" {}

resource "random_id" "db_name_suffix_destination" {
  byte_length = 4
}

resource "postgresql_extension" "pglogical" {
  for_each = toset(var.migration_databases)
  name     = "pglogical"
  database = each.value
  depends_on = [
    module.database
  ]
}

resource "google_database_migration_service_connection_profile" "connection_profile" {
  project               = var.gcp_project
  location              = var.region
  connection_profile_id = "${google_sql_database_instance.instance.name}-id"
  display_name          = "${google_sql_database_instance.instance.name}-connection-profile"

  postgresql {
    cloud_sql_id = google_sql_database_instance.instance.name
    host         = google_sql_database_instance.instance.private_ip_address
    port         = var.database_port

    username = postgresql_role.migration.name
    password = postgresql_role.migration.password
  }
}

resource "random_password" "migration" {
  length  = 20
  special = false
}

resource "postgresql_role" "migration" {
  name        = "${var.instance_name}-migration"
  password    = random_password.migration.result
  login       = true
  replication = true
}

resource "postgresql_grant" "grant_connect_db_migration_user" {
  for_each    = toset(var.migration_databases)
  database    = each.value
  role        = postgresql_role.migration.name
  object_type = "database"
  privileges  = ["CONNECT", "TEMPORARY"]
  depends_on = [
    module.database,
  ]
}

resource "postgresql_grant" "grant_usage_public_schema_migration_user" {
  for_each    = toset(var.migration_databases)
  database    = each.value
  role        = postgresql_role.migration.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]

  depends_on = [
    module.database,
    postgresql_grant.grant_connect_db_migration_user
  ]
}

resource "postgresql_grant" "grant_usage_pglogical_schema_migration_user" {
  for_each    = toset(var.migration_databases)
  database    = each.value
  role        = postgresql_role.migration.name
  schema      = "pglogical"
  object_type = "schema"
  privileges  = ["USAGE"]

  depends_on = [
    module.database,
    postgresql_extension.pglogical,
    postgresql_grant.grant_usage_public_schema_migration_user
  ]
}

resource "postgresql_grant" "grant_usage_pglogical_schema_public_user" {
  for_each    = toset(var.migration_databases)
  database    = each.value
  role        = "public"
  schema      = "pglogical"
  object_type = "schema"

  privileges = ["USAGE"]

  depends_on = [
    module.database,
    postgresql_extension.pglogical,
    postgresql_grant.grant_usage_pglogical_schema_migration_user
  ]
}

resource "postgresql_grant" "grant_select_table_pglogical_schema_migration_user" {
  for_each    = toset(var.migration_databases)
  database    = each.value
  role        = postgresql_role.migration.name
  schema      = "pglogical"
  object_type = "table"

  privileges = ["SELECT"]

  depends_on = [
    module.database,
    postgresql_extension.pglogical,
    postgresql_grant.grant_usage_pglogical_schema_public_user
  ]
}

resource "postgresql_grant" "grant_select_table_public_schema_migration_user" {
  for_each    = toset(var.migration_databases)
  database    = each.value
  role        = postgresql_role.migration.name
  schema      = "public"
  object_type = "table"

  privileges = ["SELECT"]

  depends_on = [
    module.database,
    postgresql_grant.grant_select_table_pglogical_schema_migration_user
  ]
}

resource "postgresql_grant" "grant_select_sequence_public_schema_migration_user" {
  for_each    = toset(var.migration_databases)
  database    = each.value
  role        = postgresql_role.migration.name
  schema      = "public"
  object_type = "sequence"

  privileges = ["SELECT"]

  depends_on = [
    module.database,
    postgresql_grant.grant_select_table_pglogical_schema_migration_user
  ]
}

resource "google_sql_database_instance" "destination_instance" {
  name = "${var.instance_name}-${random_id.db_name_suffix_destination.hex}"

  project             = var.gcp_project
  database_version    = var.destination_database_version
  region              = var.region
  deletion_protection = !var.destroyable

  settings {
    tier                        = var.tier
    availability_type           = var.highly_available ? "REGIONAL" : "ZONAL"
    deletion_protection_enabled = !var.destroyable

    dynamic "database_flags" {
      for_each = var.max_connections > 0 ? [var.max_connections] : []
      content {
        name  = "max_connections"
        value = var.max_connections
      }
    }

    dynamic "database_flags" {
      for_each = var.enable_detailed_logging ? [{
        name  = "log_statement"
        value = "all"
        }, {
        name  = "log_lock_waits"
        value = "on"
      }] : []
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "database_flags" {
      for_each = var.replication ? ["on"] : []
      content {
        name  = "cloudsql.logical_decoding"
        value = "on"
      }
    }

    backup_configuration {
      enabled                        = false
      point_in_time_recovery_enabled = false
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = true
    }
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.22.0"
    }
  }
}
