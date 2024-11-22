variable "name_prefix" {}
variable "gcp_project" {}
variable "organization_id" { default = "" }
variable "external_users" { default = [] }
variable "tf_state_bucket_location" {
  default = "US-EAST1"
}
variable "tf_state_bucket_force_destroy" {
  default = false
}
variable "tf_state_bucket_name" {
  default = ""
}
variable "enable_services" {
  default = true
}

locals {
  organization_id               = var.organization_id
  external_users                = var.external_users
  name_prefix                   = var.name_prefix
  tf_state_bucket_location      = var.tf_state_bucket_location
  tf_state_bucket_force_destroy = var.tf_state_bucket_force_destroy
  tf_state_bucket_name          = var.tf_state_bucket_name != "" ? var.tf_state_bucket_name : "${var.name_prefix}-tf-state"
  project                       = var.gcp_project
}
