data "google_compute_network" "vpc" {
  project = local.gcp_project
  name    = local.vpc_name
}

resource "google_compute_global_address" "peering" {
  provider = google-beta

  project       = local.gcp_project
  name          = "${local.instance_name}-peering"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = data.google_compute_network.vpc.id
}

resource "google_service_networking_connection" "postgresql" {
  provider                = google-beta
  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.peering.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  name = "${local.instance_name}-${random_id.db_name_suffix.hex}"

  project             = local.gcp_project
  database_version    = "POSTGRES_14"
  region              = local.region
  deletion_protection = !local.destroyable

  settings {
    tier              = local.tier
    availability_type = local.highly_available ? "REGIONAL" : "ZONAL"

    dynamic "database_flags" {
      for_each = local.max_connections > 0 ? [local.max_connections] : []
      content {
        name  = "max_connections"
        value = local.max_connections
      }
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = data.google_compute_network.vpc.id
    }
  }

  depends_on = [google_service_networking_connection.postgresql]

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

  gcp_project                 = local.gcp_project
  db_name                     = each.value
  admin_user_name             = google_sql_user.admin.name
  user_name                   = "${each.value}-user"
  pg_instance_connection_name = google_sql_database_instance.instance.connection_name
}

provider "postgresql" {
  host     = google_sql_database_instance.instance.private_ip_address
  username = google_sql_user.admin.name
  password = random_password.admin.result

  # GCP doesn't let superuser mode https://cloud.google.com/sql/docs/postgres/users#superuser_restrictions
  superuser = false
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.17.1"
    }
  }
}