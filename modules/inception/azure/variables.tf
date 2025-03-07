variable "name_prefix" {
}
variable "subscription_id" {}
variable "network_prefix" {
  default = "10.0"
}
variable "resource_group_name" {
}
variable "tf_state_storage_location" {}

locals {
  name_prefix               = var.name_prefix
  subscription_id           = var.subscription_id
  network_prefix            = var.network_prefix
  resource_group_name       = var.resource_group_name
  tf_state_storage_location = var.tf_state_storage_location
}
