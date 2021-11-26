resource "google_compute_global_address" "peering" {
  provider = google-beta

  project       = local.project
  name          = "${local.name_prefix}-peering"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.vpc.id
}

resource "google_service_networking_connection" "cloud_sql" {
  provider                = google-beta
  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.peering.name]
}

module "shared_pg" {
  count  = local.deploy_shared_pg ? 1 : 0
  source = "./cloud-sql"

  project              = local.project
  vpc_id               = data.google_compute_network.vpc.id
  region               = local.region
  instance_name        = "${local.name_prefix}-shared-pg"
  destroyable_postgres = var.destroyable_postgres
  highly_available     = false
  postgres_tier        = local.postgres_tier

  depends_on = [google_service_networking_connection.cloud_sql]
}
