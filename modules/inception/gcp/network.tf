resource "google_compute_network" "vpc" {
  project                 = local.project
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "dmz" {
  project = local.project
  region  = local.region
  name    = "${local.name_prefix}-dmz"

  network = google_compute_network.vpc.self_link

  private_ip_google_access = true
  ip_cidr_range            = "${local.network_prefix}.0.0/24"
}

resource "google_compute_global_address" "peering" {
  provider = google-beta

  project       = local.project
  name          = "${local.name_prefix}-peering"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "service" {
  provider                = google-beta
  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.peering.name]
}
