variable "name_prefix" {}
variable "resource_group_name" {}

module "inception" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/inception/azure?ref=b276fd3"
  source = "../../../modules/inception/azure"

  name_prefix         = var.name_prefix
  resource_group_name = var.resource_group_name
}

output "vnet_name" {
  value = module.inception.vnet_name
}
output "bastion_public_ip" {
  value = module.inception.bastion_public_ip
}
output "bastion_password" {
  value     = module.inception.bastion_password
  sensitive = true
}

provider "azurerm" {
  features {}
}
