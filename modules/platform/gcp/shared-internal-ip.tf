
resource "google_compute_address" "shared_ip" {
  project = local.project
  name    = "${local.name_prefix}-internal"
  region  = local.region

  subnetwork   = google_compute_subnetwork.cluster.id
  address_type = "INTERNAL"
  address      = local.shared_internal_ip_address
  purpose      = "SHARED_LOADBALANCER_VIP"
}
