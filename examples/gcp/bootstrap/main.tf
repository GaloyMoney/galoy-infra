variable "name_prefix" {}
variable "gcp_project" {}
variable "enable_services" {
  default = true
}

module "bootstrap" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/gcp?ref=54d3172"
  # source = "../../../modules/bootstrap/gcp"

  name_prefix     = var.name_prefix
  gcp_project     = var.gcp_project
  enable_services = var.enable_services
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
