variable "name_prefix" {}
variable "gcp_project" {}
variable "region" {
  default = "us-east1"
}
variable "network_prefix" {
  default = "10.1"
}
variable "kube_version" {
  default = "1.21.5-gke.1302"
}
variable "node_default_machine_type" {
  default = "n2-standard-4"
}
variable "postgres_tier" {
  default = "db-f1-micro"
}
variable "destroyable_postgres" {
  default = false
}
variable "node_service_account" {}
variable "min_default_node_count" {
  default = 1
}
variable "max_default_node_count" {
  default = 3
}

locals {
  name_prefix               = var.name_prefix
  cluster_name              = "${var.name_prefix}-cluster"
  master_ipv4_cidr_block    = "172.16.0.0/28"
  project                   = var.gcp_project
  region                    = var.region
  network_prefix            = var.network_prefix
  kube_version              = var.kube_version
  node_default_machine_type = var.node_default_machine_type
  nodes_service_account     = var.node_service_account
  min_default_node_count    = var.min_default_node_count
  max_default_node_count    = var.max_default_node_count
  cluster_location          = local.region
  postgres_tier             = var.postgres_tier
  destroyable_postgres     = var.destroyable_postgres
}
