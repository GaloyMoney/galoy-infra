variable "name_prefix" {
}
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
locals {
  name_prefix               = var.name_prefix
  network_prefix            = var.network_prefix
  resource_group_name       = var.resource_group_name
  node_default_machine_type = var.node_default_machine_type
  vnet_name                 = var.vnet_name
  cluster_name              = var.cluster_name
  cluster_location          = var.cluster_location
}
