variable "name_prefix" {}
variable "gcp_project" {}

module "platform" {
  # source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/platform/gcp?ref=0a0f925"
  source = "../../../modules/platform/gcp"

  name_prefix = var.name_prefix
  gcp_project = var.gcp_project
}
