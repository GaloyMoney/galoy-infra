variable "name_prefix" {}
module "inception" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/inception/azure?ref=b276fd3"
  #source = "../../../modules/inception/azure"

  name_prefix = var.name_prefix
}
