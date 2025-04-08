variable "name_prefix" {}

module "inception" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/inception/azure?ref=a5c4dec"
  source = "../../../modules/inception/azure"

  name_prefix = var.name_prefix
}

output "vnet_name" {
  value = module.inception.vnet_name
}
output "bastion_public_ip" {
  value = module.inception.bastion_public_ip
}
