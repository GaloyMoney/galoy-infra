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
