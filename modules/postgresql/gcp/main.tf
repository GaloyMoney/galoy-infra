data "google_compute_network" "vpc" {
  project = local.gcp_project
  name    = local.vpc_name
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "postgresql_extension" "pglogical" {
  count    = local.upgradable ? 1 : 0
  name     = "pglogical"
  database = "postgres"
}

resource "google_database_migration_service_connection_profile" "connection_profile" {
  count                 = local.upgradable ? 1 : 0
  project               = local.gcp_project
  location              = local.region
  connection_profile_id = "${google_sql_database_instance.instance.name}-id"
  display_name          = "${google_sql_database_instance.instance.name}-connection-profile"

  postgresql {
    cloud_sql_id = google_sql_database_instance.instance.name
    host         = google_sql_database_instance.instance.private_ip_address
    port         = local.database_port

    username = google_sql_user.admin.name
    password = google_sql_user.admin.password
  }
  depends_on = [google_sql_database_instance.instance]
}

resource "google_sql_database_instance" "instance" {
  name = "${local.instance_name}-${random_id.db_name_suffix.hex}"

  project             = local.gcp_project
  database_version    = local.database_version
  region              = local.region
  deletion_protection = !local.destroyable

  settings {
    tier                        = local.tier
    availability_type           = local.highly_available ? "REGIONAL" : "ZONAL"
    deletion_protection_enabled = !local.destroyable

    dynamic "database_flags" {
      for_each = local.upgradable ? [{
        name  = "cloudsql.logical_decoding"
        value = "on"
        }, {
        name  = "cloudsql.enable_pglogical"
        value = "on"
        }, {
        # for exporting users after the database is migrated
        name  = "cloudsql.pg_shadow_select_role"
        value = "${local.instance_name}-admin"
        }
      ] : []
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    dynamic "database_flags" {
      for_each = local.max_connections > 0 ? [local.max_connections] : []
      content {
        name  = "max_connections"
        value = local.max_connections
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
      for_each = local.replication ? ["on"] : []
      content {
        name  = "cloudsql.logical_decoding"
        value = "on"
      }
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
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

resource "random_password" "admin" {
  length  = 20
  special = false
}

resource "google_sql_user" "admin" {
  name     = "${local.instance_name}-admin"
  instance = google_sql_database_instance.instance.name
  password = random_password.admin.result
  project  = local.gcp_project
}

module "database" {
  for_each = toset(local.databases)
  source   = "./database"

  gcp_project                   = local.gcp_project
  db_name                       = each.value
  admin_user_name               = google_sql_user.admin.name
  user_name                     = "${each.value}-user"
  user_can_create_db            = var.user_can_create_db
  pg_instance_connection_name   = google_sql_database_instance.instance.connection_name
  connection_users              = local.big_query_viewers
  replication                   = local.replication
  big_query_connection_location = local.big_query_connection_location
  upgradable                    = local.upgradable
}

provider "postgresql" {
  host     = google_sql_database_instance.instance.private_ip_address
  port     = local.database_port
  username = google_sql_user.admin.name
  password = random_password.admin.result

  # GCP doesn't let superuser mode https://cloud.google.com/sql/docs/postgres/users#superuser_restrictions
  superuser = false
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.22.0"
    }
  }
}
