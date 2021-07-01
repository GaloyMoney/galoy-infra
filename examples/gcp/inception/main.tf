variable "name_prefix" {}
variable "tf_state_bucket_name" {}
variable "gcp_project" {}
variable "inception_sa" {}

module "inception" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/inception/gcp?ref=462ae1a"
  # source = "../../../modules/inception/gcp"

  name_prefix          = var.name_prefix
  gcp_project          = var.gcp_project
  inception_sa         = var.inception_sa
  tf_state_bucket_name = var.tf_state_bucket_name
}
