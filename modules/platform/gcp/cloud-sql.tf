resource "google_compute_global_address" "shared" {
  count    = local.deploy_shared_pg ? 1 : 0
  provider = google-beta

  project       = local.project
  name          = "${local.name_prefix}-shared-pg-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.vpc.id
}

resource "google_service_networking_connection" "shared" {
  count                   = local.deploy_shared_pg ? 1 : 0
  provider                = google-beta
  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.shared.0.name]
}

resource "random_id" "shared_db_name_suffix" {
  count       = local.deploy_shared_pg ? 1 : 0
  byte_length = 4
}

resource "google_sql_database_instance" "shared" {
  count = local.deploy_shared_pg ? 1 : 0
  name  = "${local.name_prefix}-shared-pg-${random_id.shared_db_name_suffix.0.hex}"

  project             = local.project
  database_version    = "POSTGRES_13"
  region              = local.region
  deletion_protection = !local.destroyable_postgres

  depends_on = [google_service_networking_connection.shared.0]

  settings {
    tier              = local.postgres_tier
    availability_type = "ZONAL"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.vpc.id
    }
  }
}

resource "random_password" "shared" {
  count   = local.deploy_shared_pg ? 1 : 0
  length  = 20
  special = false
}

resource "google_sql_user" "shared" {
  count    = local.deploy_shared_pg ? 1 : 0
  name     = "shared_admin"
  instance = google_sql_database_instance.shared.0.name
  password = random_password.shared.0.result
  project  = local.project
}
