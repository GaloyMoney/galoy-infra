variable "name_prefix" {}
variable "gcp_project" {}
variable "organization_id" {}
variable "external_users" {}
variable "tf_state_bucket_location" {
  default = "US-EAST1"
}
variable "tf_state_bucket_force_destroy" {
  default = false
}
variable "enable_services" {
  default = true
}

locals {
  name_prefix                   = var.name_prefix
  organization_id               = var.organization_id
  external_users                = var.external_users
  tf_state_bucket_location      = var.tf_state_bucket_location
  tf_state_bucket_force_destroy = var.tf_state_bucket_force_destroy
  project                       = var.gcp_project
}
