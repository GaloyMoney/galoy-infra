variable "name_prefix" {}
variable "gcp_project" {}
variable "tf_state_bucket_location" {
  default = "US"
}

locals {
  name_prefix              = var.name_prefix
  tf_state_bucket_location = var.tf_state_bucket_location
  project                  = var.gcp_project
}
