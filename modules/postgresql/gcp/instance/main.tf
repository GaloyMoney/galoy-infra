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
  deletion_protection = !local.destroyable

  settings {
    tier                        = local.tier
    edition                     = "ENTERPRISE"
    availability_type           = local.highly_available ? "REGIONAL" : "ZONAL"
    deletion_protection_enabled = !local.destroyable
    insights_config {
      query_insights_enabled = local.query_insights_enabled
    }

    dynamic "database_flags" {
      for_each = local.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    backup_configuration {
      enabled                        = local.backup_enabled
      point_in_time_recovery_enabled = local.point_in_time_recovery_enabled
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

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
