variable "name_prefix" {}
variable "external_users" { default = [] }
variable "tenant_id" {}
variable "tf_state_bucket_location" {
  default = "eastus"
}
variable "tf_state_bucket_force_destroy" {
  default = false
}
variable "resource_group_location" {
	default = "eastus"
}

locals {
  tenant_id						= var.tenant_id
  external_users                = var.external_users
  name_prefix                   = var.name_prefix
  resource_group_location		= var.resource_group_location
  tf_state_bucket_location      = var.tf_state_bucket_location
  tf_state_bucket_force_destroy = var.tf_state_bucket_force_destroy
}
