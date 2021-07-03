variable "name_prefix" {}
variable "gcp_project" {}
variable "region" {
  default = "us-east1"
}
variable "primary_zone" {
  default = "b"
}
variable "network_prefix" {
  default = "10.1"
}
variable "kube_version" {
  default = "1.19.10-gke.1600"
}
variable "node_default_machine_type" {
  default = "e2-standard-4"
}
variable "node_service_account" {}

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
}
