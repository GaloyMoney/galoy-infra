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
  highly_available     = local.pg_ha
  postgres_tier        = local.postgres_tier

  depends_on = [google_service_networking_connection.cloud_sql]
}

module "auth_pg" {
  count  = local.deploy_auth_pg ? 1 : 0
  source = "./cloud-sql"

  project              = local.project
  vpc_id               = data.google_compute_network.vpc.id
  region               = local.region
  instance_name        = "${local.name_prefix}-auth-pg"
  destroyable_postgres = var.destroyable_postgres
  highly_available     = local.pg_ha
  postgres_tier        = local.postgres_tier

  depends_on = [google_service_networking_connection.cloud_sql]
}

module "lnd1_pg" {
  count  = local.deploy_lnd1_pg ? 1 : 0
  source = "./cloud-sql"

  project              = local.project
  vpc_id               = data.google_compute_network.vpc.id
  region               = local.region
  instance_name        = "${local.name_prefix}-lnd-1-pg"
  destroyable_postgres = var.destroyable_postgres
  highly_available     = local.pg_ha
  postgres_tier        = local.postgres_tier

  depends_on = [google_service_networking_connection.cloud_sql]
}

module "lnd2_pg" {
  count  = local.deploy_lnd2_pg ? 1 : 0
  source = "./cloud-sql"

  project              = local.project
  vpc_id               = data.google_compute_network.vpc.id
  region               = local.region
  instance_name        = "${local.name_prefix}-lnd-2-pg"
  destroyable_postgres = var.destroyable_postgres
  highly_available     = local.pg_ha
  postgres_tier        = local.postgres_tier

  depends_on = [google_service_networking_connection.cloud_sql]
}
