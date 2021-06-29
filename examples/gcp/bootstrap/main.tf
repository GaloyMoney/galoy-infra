variable "name_prefix" {}
variable "gcp_project" {}

module "bootstrap" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/gcp?ref=b397ae8"

  name_prefix = var.name_prefix
  gcp_project = var.gcp_project
}
