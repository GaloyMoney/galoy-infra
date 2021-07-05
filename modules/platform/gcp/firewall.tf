resource "google_compute_firewall" "intra_egress" {
  project     = local.project
  name        = "${local.name_prefix}-intra-cluster-egress"
  description = "Allow pods to communicate with each other and the master"
  network     = data.google_compute_network.vpc.self_link
  priority    = 1000
  direction   = "EGRESS"

  target_tags = [local.cluster_name]
  destination_ranges = [
    local.master_ipv4_cidr_block,
    google_compute_subnetwork.cluster.ip_cidr_range,
    google_compute_subnetwork.cluster.secondary_ip_range[0].ip_cidr_range,
  ]

  # Allow all possible protocols
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
  allow { protocol = "sctp" }
  allow { protocol = "esp" }
  allow { protocol = "ah" }
}

resource "google_compute_firewall" "webhook_ingress" {
  project     = local.project
  name        = "${local.name_prefix}-webhook-ingress"
  description = "Allow master to call webhooks"
  network     = data.google_compute_network.vpc.self_link
  priority    = 1000
  direction   = "INGRESS"

  target_tags = [local.cluster_name]
  source_ranges = [
    local.master_ipv4_cidr_block,
  ]

  allow {
    protocol = "tcp"
    ports    = [8443, 443]
  }
}

resource "google_compute_firewall" "dmz_nodes_ingress" {
  name        = "${var.name_prefix}-bastion-nodes-ingress"
  description = "Allow ${var.name_prefix}-bastion to reach nodes"
  project     = local.project
  network     = data.google_compute_network.vpc.self_link
  priority    = 1000
  direction   = "INGRESS"

  target_tags = [local.cluster_name]
  source_ranges = [
    data.google_compute_subnetwork.dmz.ip_cidr_range,
  ]

  # Allow all possible protocols
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
  allow { protocol = "sctp" }
  allow { protocol = "esp" }
  allow { protocol = "ah" }
}
