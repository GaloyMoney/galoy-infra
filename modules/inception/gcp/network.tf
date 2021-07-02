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
