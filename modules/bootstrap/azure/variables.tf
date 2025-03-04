variable "name_prefix" {}
variable "tf_state_storage_location" {
  default = "eastus"
}
variable "tf_state_storage_force_destroy" {
  default = false
}
variable "resource_group_location" {
  default = "eastus"
}

locals {
  name_prefix                    = var.name_prefix
  resource_group_location        = var.resource_group_location
  tf_state_storage_location      = var.tf_state_storage_location
  tf_state_storage_force_destroy = var.tf_state_storage_force_destroy
  inception_app_name             = "${local.name_prefix}-inception-tf"
}
