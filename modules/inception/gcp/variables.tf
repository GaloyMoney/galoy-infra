variable "name_prefix" {}
variable "gcp_project" {}
variable "inception_sa" {}
variable "tf_state_bucket_name" {}

locals {
  name_prefix          = var.name_prefix
  tf_state_bucket_name = var.tf_state_bucket_name
  project              = var.gcp_project
  inception_sa         = var.inception_sa
}
