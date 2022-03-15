locals {
  tag             = "${local.name_prefix}-bastion"
  cfssl_version   = "1.6.1"
  bitcoin_version = "22.0"
  cepler_version  = "0.7.5"
  lnd_version     = "0.13.3"
  kubectl_version = "1.21.3"
  k9s_version     = "0.25.18"
}

resource "google_service_account" "bastion" {
  project      = local.project
  account_id   = "${local.name_prefix}-bastion"
  display_name = "Bastion account for ${local.name_prefix}"

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
    zone : local.region,
    project : local.project,
    bastion_revoke_on_exit : local.bastion_revoke_on_exit
    cfssl_version : local.cfssl_version,
    bitcoin_version : local.bitcoin_version
    cepler_version : local.cepler_version
    kubectl_version : local.kubectl_version
    k9s_version : local.k9s_version
    lnd_version : local.lnd_version
  })
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
  name = "${local.name_prefix}-bastion-allow-iap-ingress"

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

resource "google_service_account_iam_member" "bastion_account_iam" {
  for_each = toset(local.bastion_users)

  service_account_id = google_service_account.bastion.name
  role               = "roles/iam.serviceAccountUser"
  member             = each.key
}

resource "google_project_iam_member" "ssh_access" {
  for_each = toset([for email in local.bastion_access : "user:${email}"])

  role   = "roles/iap.tunnelResourceAccessor"
  member = each.key
}
