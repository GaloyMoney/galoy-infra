variable "name_prefix" {}
variable "tf_state_bucket_name" {}
variable "tf_state_bucket_location" {
  default = "US"
}
variable "gcp_project" {}
variable "inception_sa" {}
variable "users" {
  type = list(object({
    id = string
    inception = bool
  }))
}

module "inception" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/inception/gcp?ref=9b55501"
  # source = "../../../modules/inception/gcp"

  name_prefix          = var.name_prefix
  gcp_project          = var.gcp_project
  inception_sa         = var.inception_sa
  tf_state_bucket_name = var.tf_state_bucket_name
  tf_state_bucket_location = var.tf_state_bucket_location

  users = var.users
}
