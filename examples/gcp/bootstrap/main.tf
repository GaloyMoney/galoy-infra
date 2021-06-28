variable name_prefix {}

module "bootstrap" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/gcp?ref=f19ab4e"

  name_prefix = var.name_prefix
}
