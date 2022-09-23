locals {
  pods_range_name = "${local.name_prefix}-pods"
  svc_range_name  = "${local.name_prefix}-svc"
}

data "google_compute_network" "vpc" {
  project = local.project
  name    = "${local.name_prefix}-vpc"
}

resource "google_compute_subnetwork" "cluster" {
  name = "${local.name_prefix}-cluster"

  project = local.project
  region  = local.region
  network = data.google_compute_network.vpc.self_link

  private_ip_google_access = true
  ip_cidr_range            = "${local.network_prefix}.0.0/17"
  secondary_ip_range {
    range_name    = local.pods_range_name
    ip_cidr_range = "192.168.0.0/18"
  }
  secondary_ip_range {
    range_name    = local.svc_range_name
    ip_cidr_range = "192.168.64.0/18"
  }
}

resource "google_compute_global_address" "peering" {
  provider = google-beta

  project       = local.project
  name          = "${local.name_prefix}-peering"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.vpc.id
}

resource "google_service_networking_connection" "service" {
  provider                = google-beta
  network                 = data.google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.peering.name]
}
