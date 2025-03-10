variable "name_prefix" {}
variable "network_prefix" {
  default = "10.1"
}
variable "node_default_machine_type" {
  default = "Standard_DS2_v2"
}
variable "vnet_name" {}
variable "cluster_location" {
  default = "eastus"
}
variable "kube_version" {
  default = "1.30.9"
}
variable "min_default_node_count" {
  default = 1
}
variable "max_default_node_count" {
  default = 3
}
locals {
  name_prefix               = var.name_prefix
  network_prefix            = var.network_prefix
  resource_group_name       = var.name_prefix
  node_default_machine_type = var.node_default_machine_type
  vnet_name                 = var.vnet_name
  cluster_name              = "${var.name_prefix}-cluster"
  cluster_location          = var.cluster_location
  kube_version              = var.kube_version
  min_default_node_count    = var.min_default_node_count
  max_default_node_count    = var.max_default_node_count
}
