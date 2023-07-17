locals {
  tag             = "${local.name_prefix}-bastion"
  bria_version    = "0.1.37"
  cfssl_version   = "1.6.1"
  bitcoin_version = "24.0.1"
  cepler_version  = "0.7.9"
  safe_version    = "1.7.0"
  lnd_version     = "0.15.5"
  kubectl_version = "1.24.12"
  k9s_version     = "0.25.18"
  bos_version     = "12.13.3"
  kratos_version  = "0.11.1"
}

resource "google_compute_instance" "bastion" {
  project      = local.project
  name         = "${local.name_prefix}-bastion"
  machine_type = local.bastion_machine_type
  zone         = local.bastion_zone

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = [local.tag]

  boot_disk {
    initialize_params {
      image = local.bastion_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.dmz.self_link
  }

  metadata = {
    enable-oslogin     = "TRUE"
    enable-oslogin-2fa = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/bastion-startup.tmpl", {
    cluster_name : "${local.name_prefix}-cluster",
    zone : local.cluster_location,
    project : local.project,
    bastion_revoke_on_exit : local.bastion_revoke_on_exit
    bria_version : local.bria_version,
    cfssl_version : local.cfssl_version,
    bitcoin_version : local.bitcoin_version
    cepler_version : local.cepler_version
    safe_version : local.safe_version
    kubectl_version : local.kubectl_version
    k9s_version : local.k9s_version
    lnd_version : local.lnd_version
    bos_version : local.bos_version
    kratos_version : local.kratos_version
  })

  depends_on = [
    google_compute_router_nat.main
  ]
}

data "google_iam_policy" "bastion" {
  binding {
    role    = "roles/compute.osLogin"
    members = local.bastion_users
  }
  binding {
    role    = "roles/compute.viewer"
    members = local.bastion_users
  }
  binding {
    role    = "roles/compute.admin"
    members = ["serviceAccount:${local.inception_sa}"]
  }
}

resource "google_compute_instance_iam_policy" "bastion" {
  project       = local.project
  zone          = google_compute_instance.bastion.zone
  instance_name = google_compute_instance.bastion.name
  policy_data   = data.google_iam_policy.bastion.policy_data
}

resource "google_compute_firewall" "bastion_allow_iap_inbound" {
  project = local.project
  name    = "${local.name_prefix}-bastion-allow-iap-ingress"

  network = google_compute_network.vpc.self_link

  target_tags   = [local.tag]
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]

  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = [22]
  }
}
