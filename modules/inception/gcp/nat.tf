resource "google_compute_router" "router" {
  name    = "${local.name_prefix}-router"
  project = local.project
  region  = local.region
  network = google_compute_network.vpc.self_link
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "main" {
  name                               = "${local.name_prefix}-nat"
  project                            = local.project
  region                             = local.region
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
