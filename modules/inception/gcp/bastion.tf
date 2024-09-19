locals {
  tag              = "${local.name_prefix}-bastion"
  bria_version     = "0.1.106"
  bitcoin_version  = "25.2"
  cepler_version   = "0.7.15"
  lnd_version      = "0.18.0-beta"
  kubectl_version  = "1.30.4"
  k9s_version      = "0.32.5"
  bos_version      = "18.2.0"
  kratos_version   = "0.11.1"
  opentofu_version = "1.8.2"
}
data "google_compute_image" "bastion" {
  family      = local.bastion_image_family
  project     = local.bastion_image_project
  most_recent = true
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
      image = data.google_compute_image.bastion.self_link
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
    bitcoin_version : local.bitcoin_version
    cepler_version : local.cepler_version
    kubectl_version : local.kubectl_version
    k9s_version : local.k9s_version
    lnd_version : local.lnd_version
    bos_version : local.bos_version
    kratos_version : local.kratos_version
    opentofu_version : local.opentofu_version
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

resource "google_project_iam_audit_config" "iap_audit_logs" {
  project = local.project
  service = "iap.googleapis.com"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}
