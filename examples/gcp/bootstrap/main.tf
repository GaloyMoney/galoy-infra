variable project {}
variable name_prefix {}

provider "google" {
  project      = var.project
}

module "bootstrap" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/gcp?ref=e2b9ef4"

  name_prefix = var.name_prefix
}
