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
  provider                = google-beta
  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.postgres.name]
}

# resource "random_id" "db_name_suffix" {
#   byte_length = 4
# }

# resource "google_sql_database_instance" "postgres" {
#   name = "${local.name_prefix}-pg-${random_id.db_name_suffix.hex}"

#   project             = local.project
#   database_version    = "POSTGRES_13"
#   region              = local.region
#   deletion_protection = !local.destroyable_postgres

#   depends_on = [google_service_networking_connection.postgres]

#   settings {
#     tier              = local.postgres_tier
#     availability_type = "REGIONAL"

#     backup_configuration {
#       enabled                        = true
#       point_in_time_recovery_enabled = true
#     }

#     ip_configuration {
#       ipv4_enabled    = false
#       private_network = data.google_compute_network.vpc.id
#     }
#   }
# }
