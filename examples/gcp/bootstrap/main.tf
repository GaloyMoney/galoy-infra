variable "name_prefix" {}
variable "gcp_project" {}
variable "enable_services" {
  default = true
}
variable "tf_state_bucket_force_destroy" {
  default = false
}

module "bootstrap" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/gcp?ref=3cc3eb4"
  # source = "../../../modules/bootstrap/gcp"

  name_prefix                   = var.name_prefix
  gcp_project                   = var.gcp_project
  enable_services               = var.enable_services
  tf_state_bucket_force_destroy = var.tf_state_bucket_force_destroy
}

output "inception_sa" {
  value = module.bootstrap.inception_sa
}
output "name_prefix" {
  value = var.name_prefix
}
output "gcp_project" {
  value = var.gcp_project
}
output "tf_state_bucket_name" {
  value = module.bootstrap.tf_state_bucket_name
}
output "tf_state_bucket_location" {
  value = module.bootstrap.tf_state_bucket_location
}
