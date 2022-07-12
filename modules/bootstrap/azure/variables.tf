variable "name_prefix" {}
variable "tf_state_storage_location" {
  default = "eastus"
}
variable "resource_group_location" {
  default = "eastus"
}

locals {
  name_prefix               = var.name_prefix
  tf_state_storage_location = var.tf_state_storage_location
  resource_group_location   = var.resource_group_location
  inception_app_name        = "${local.name_prefix}-inception-tf"
}
