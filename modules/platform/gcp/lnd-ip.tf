resource "google_compute_address" "lnd1" {
  project = local.project
  name    = "${local.name_prefix}-lnd1"
  region  = local.region
}

resource "google_compute_address" "lnd2" {
  project = local.project
  name    = "${local.name_prefix}-lnd2"
  region  = local.region
}

resource "google_compute_address" "lnd1_internal_ip" {
  project = local.project
  name    = "${local.name_prefix}-internal"
  region  = local.region

  subnetwork   = google_compute_subnetwork.cluster.id
  address_type = "INTERNAL"
  address      = local.lnd1_internal_ip
  purpose      = "SHARED_LOADBALANCER_VIP"
}

resource "google_compute_address" "lnd2_internal_ip" {
  project = local.project
  name    = "${local.name_prefix}-internal"
  region  = local.region

  subnetwork   = google_compute_subnetwork.cluster.id
  address_type = "INTERNAL"
  address      = local.lnd2_internal_ip
  purpose      = "SHARED_LOADBALANCER_VIP"
}
