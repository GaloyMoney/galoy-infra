locals {
  max_pods_per_node = 110
}

data "google_compute_subnetwork" "dmz" {
  project = local.project
  name    = "${local.name_prefix}-dmz"
  region  = local.region
}

resource "google_container_cluster" "primary" {
  provider = google-beta

  min_master_version = local.kube_version
  name               = local.cluster_name
  description        = "Cluster hosting the ${local.name_prefix} apps"
  project            = local.project

  location = local.region
  network  = data.google_compute_network.vpc.self_link

  release_channel {
    channel = "UNSPECIFIED"
  }

  subnetwork = google_compute_subnetwork.cluster.self_link

  default_snat_status {
    disabled = false
  }

  default_max_pods_per_node = local.max_pods_per_node

  enable_binary_authorization = true
  enable_intranode_visibility = false
  enable_shielded_nodes       = true

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = data.google_compute_subnetwork.dmz.ip_cidr_range
      display_name = "DMZ"
    }
  }

  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = local.pods_range_name
    services_secondary_range_name = local.svc_range_name
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "05:00"
    }
  }

  lifecycle {
    ignore_changes = [node_pool, initial_node_count]
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

  node_pool {
    name               = "default-pool"
    initial_node_count = 0
    node_config {
      service_account = local.nodes_service_account
    }
  }

  remove_default_node_pool = true

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = local.master_ipv4_cidr_block
    master_global_access_config {
      enabled = true
    }
  }

  database_encryption {
    state    = "DECRYPTED"
    key_name = ""
  }

  workload_identity_config {
    identity_namespace = "${local.project}.svc.id.goog"
  }
}

resource "google_container_node_pool" "default" {
  provider = google-beta

  name     = "${local.name_prefix}-default-nodes"
  project  = local.project
  version  = google_container_cluster.primary.master_version
  location = google_container_cluster.primary.location

  cluster = google_container_cluster.primary.name

  max_pods_per_node = local.max_pods_per_node
  autoscaling {
    min_node_count = local.min_default_node_count
    max_node_count = local.max_default_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  upgrade_settings {
    max_surge       = 2
    max_unavailable = 1
  }

  node_config {
    image_type   = "COS"
    machine_type = local.node_default_machine_type
    labels = {
      cluster_name = local.cluster_name
      node_pool    = "${local.name_prefix}-default-nodes"
    }

    metadata = {
      cluster_name             = local.cluster_name
      node_pool                = "${local.name_prefix}-default-node-pool"
      disable-legacy-endpoints = true
    }

    tags = [
      local.cluster_name,
      "${local.cluster_name}-default-node-pool"
    ]

    local_ssd_count = 0
    disk_size_gb    = 100
    disk_type       = "pd-standard"

    service_account = local.nodes_service_account
    preemptible     = false

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
