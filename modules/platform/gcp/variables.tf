variable "name_prefix" {}
variable "gcp_project" {}
variable "region" {
  default = "us-east1"
}
variable "cluster_zone" {
  default = ""
}
variable "network_prefix" {
  default = "10.1"
}
variable "kube_version" {
  default = "1.31.8-gke.1045000"
}
variable "node_default_machine_type" {
  default = "n2-standard-4"
}
variable "destroyable_cluster" {
  default = false
}
variable "postgres_tier" {
  default = "db-f1-micro"
}
variable "pg_ha" {
  default = false
}
variable "node_service_account" {}
variable "min_default_node_count" {
  default = 1
}
variable "max_default_node_count" {
  default = 3
}
variable "deploy_lnd_ips" {
  default = false
}

locals {
  name_prefix               = var.name_prefix
  cluster_name              = "${var.name_prefix}-cluster"
  master_ipv4_cidr_block    = "172.16.0.0/28"
  project                   = var.gcp_project
  region                    = var.region
  network_prefix            = var.network_prefix
  lnd1_internal_ip          = "${local.network_prefix}.1.1"
  lnd2_internal_ip          = "${local.network_prefix}.1.2"
  kube_version              = var.kube_version
  destroyable_cluster       = var.destroyable_cluster
  node_default_machine_type = var.node_default_machine_type
  nodes_service_account     = var.node_service_account
  min_default_node_count    = var.min_default_node_count
  max_default_node_count    = var.max_default_node_count
  cluster_location          = var.cluster_zone == "" ? local.region : "${local.region}-${var.cluster_zone}"
  postgres_tier             = var.postgres_tier
  pg_ha                     = var.pg_ha
  deploy_lnd_ips            = var.deploy_lnd_ips
}
