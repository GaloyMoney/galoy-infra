variable "name_prefix" {}
variable "gcp_project" {}
variable "node_service_account" {}

module "platform" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/platform/gcp?ref=8c217a5"
  # source = "../../../modules/platform/gcp"

  name_prefix          = var.name_prefix
  gcp_project          = var.gcp_project
  node_service_account = var.node_service_account
}
