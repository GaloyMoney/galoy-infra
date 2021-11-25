terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.14.0"
    }
  }
}

resource "google_compute_global_address" "postgres" {
  provider = google-beta

  project       = local.project
  name          = "${local.name_prefix}-pg-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.vpc.id
}

resource "google_service_networking_connection" "postgres" {
  provider = google-beta

  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.postgres.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "postgres" {
  name = "${local.name_prefix}-pg-${random_id.db_name_suffix.hex}"

  project             = local.project
  database_version    = "POSTGRES_13"
  region              = local.region
  deletion_protection = !local.destroyable_postgres

  depends_on = [google_service_networking_connection.postgres]

  settings {
    tier              = local.postgres_tier
    availability_type = "REGIONAL"

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

# Master User Configuration and PG Configuration
resource "random_password" "sql_master_user_password" {
  length  = 20
  special = false
}

resource "google_sql_user" "master_user" {
  name     = "master_user"
  instance = google_sql_database_instance.postgres.name
  password = random_password.sql_master_user_password.result
}

provider "postgresql" {
  scheme   = "gcppostgres"
  host     = google_sql_database_instance.postgres.connection_name
  username = google_sql_user.master_user.name
  password = google_sql_user.master_user.password

  # GCP doesn't let you run on Superuser mode https://cloud.google.com/sql/docs/postgres/users#superuser_restrictions
  superuser = false
}

# ------------------------ Dealer specific ----------------------->

resource "random_password" "sql_dealer_password" {
  length  = 20
  special = false
}

resource "postgresql_role" "dealer_user" {
  name     = "dealer_user"
  login    = true
  password = random_password.sql_dealer_password.result
}

resource "postgresql_database" "dealer" {
  name       = "dealer"
  owner      = google_sql_user.master_user.name
  template   = "template0"
  lc_collate = "DEFAULT"
}

output "dealer_password" {
  value     = random_password.sql_dealer_password.result
  sensitive = true
}

resource "postgresql_grant" "revoke_public_dealer" {
  database    = "dealer"
  role        = "public"
  object_type = "database"
  privileges  = []

  depends_on = [
    postgresql_database.dealer
  ]
}

resource "postgresql_grant" "grant_all_dealer" {
  database    = "dealer"
  role        = "dealer_user"
  object_type = "database"
  privileges  = ["ALL"]

  depends_on = [
    postgresql_database.dealer,
    postgresql_grant.revoke_public_dealer,
  ]
}

# ------------------------ Admin Panel specific ----------------------->

resource "random_password" "sql_admin_panel_password" {
  length  = 20
  special = false
}

resource "postgresql_role" "admin_panel_user" {
  name     = "admin_panel_user"
  login    = true
  password = random_password.sql_admin_panel_password.result
}

resource "postgresql_database" "admin_panel" {
  name       = "admin_panel"
  owner      = google_sql_user.master_user.name
  template   = "template0"
  lc_collate = "DEFAULT"
}

output "admin_panel_password" {
  value     = random_password.sql_admin_panel_password.result
  sensitive = true
}

resource "postgresql_grant" "revoke_public_admin_panel" {
  database    = "admin_panel"
  role        = "public"
  object_type = "database"
  privileges  = []

  depends_on = [
    postgresql_database.admin_panel
  ]
}

resource "postgresql_grant" "grant_all_admin_panel" {
  database    = "admin_panel"
  role        = "admin_panel_user"
  object_type = "database"
  privileges  = ["ALL"]

  depends_on = [
    postgresql_database.admin_panel,
    postgresql_grant.revoke_public_admin_panel,
  ]
}
