data "google_compute_network" "vpc" {
  project = local.gcp_project
  name    = local.vpc_name
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  name = "${local.instance_name}-${random_id.db_name_suffix.hex}"

  project             = local.gcp_project
  database_version    = local.database_version
  region              = local.region
  deletion_protection = local.prep_upgrade_as_source_db ? false : !local.destroyable

  settings {
    tier                        = local.tier
    edition                     = "ENTERPRISE"
    availability_type           = local.highly_available ? "REGIONAL" : "ZONAL"
    deletion_protection_enabled = !local.destroyable

    dynamic "database_flags" {
      for_each = local.prep_upgrade_as_source_db ? [{
        name  = "cloudsql.logical_decoding"
        value = "on"
        }, {
        name  = "cloudsql.enable_pglogical"
        value = "on"
      }] : []
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

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }

    backup_configuration {
      enabled                        = !local.pre_promotion
      point_in_time_recovery_enabled = !local.pre_promotion
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = true
      ssl_mode                                      = "ENCRYPTED_ONLY"
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

resource "google_sql_user" "iam_user" {
  for_each = toset(local.iam_users)

  name     = each.value
  instance = google_sql_database_instance.instance.name
  project  = local.gcp_project
  type     = "CLOUD_IAM_USER"
}

resource "google_project_iam_member" "cloudsql_instance_user" {
  for_each = toset(local.iam_users)

  project = local.gcp_project
  role    = "roles/cloudsql.instanceUser"
  member  = "user:${each.value}"
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
  create_read_only_user         = local.public_read_replica
  iam_users                     = local.iam_users

  depends_on = [google_sql_user.iam_user]
}

module "migration" {
  count                           = local.prep_upgrade_as_source_db ? 1 : 0
  source                          = "./migration"
  region                          = local.region
  database_port                   = local.database_port
  instance_name                   = local.instance_name
  destroyable                     = local.destroyable
  tier                            = local.tier
  highly_available                = local.highly_available
  enable_detailed_logging         = var.enable_detailed_logging
  replication                     = local.replication
  destination_database_version    = local.destination_database_version
  migration_databases             = local.migration_databases
  max_connections                 = local.max_connections
  gcp_project                     = local.gcp_project
  private_network                 = data.google_compute_network.vpc.id
  private_ip_address              = google_sql_database_instance.instance.private_ip_address
  source_destination_cloud_sql_id = google_sql_database_instance.instance.name
  depends_on                      = [google_sql_database_instance.instance, module.database]
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
      version = "1.24.0"
    }
  }
}
