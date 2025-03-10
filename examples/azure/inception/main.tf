variable "name_prefix" {}
variable "resource_group_name" {}
variable "tf_state_storage_location" {}

module "inception" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/inception/azure?ref=b276fd3"
  source = "../../../modules/inception/azure"

  name_prefix               = var.name_prefix
  subscription_id           = var.subscription_id
  resource_group_name       = var.resource_group_name
  tf_state_storage_location = var.tf_state_storage_location
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
  subscription_id = var.subscription_id
  features {}
}
