variable "subscription_id" {}
variable "name_prefix" {}
variable "network_prefix" {
  default = "10.1"
}
variable "resource_group_name" {
}
variable "node_default_machine_type" {
  default = "Standard_DS2_v2"
}
variable "vnet_name" {}
variable "cluster_name" {}
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
  subscription_id           = var.subscription_id
  name_prefix               = var.name_prefix
  network_prefix            = var.network_prefix
  resource_group_name       = var.resource_group_name
  node_default_machine_type = var.node_default_machine_type
  vnet_name                 = var.vnet_name
  cluster_name              = var.cluster_name
  cluster_location          = var.cluster_location
  kube_version              = var.kube_version
  min_default_node_count    = var.min_default_node_count
  max_default_node_count    = var.max_default_node_count
}
