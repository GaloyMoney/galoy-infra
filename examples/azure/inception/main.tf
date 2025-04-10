variable "name_prefix" {}
variable "users" {
  type = list(object({
    id        = string
    bastion   = bool
    inception = bool
    platform  = bool
    logs      = bool
  }))
}

module "inception" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/inception/azure?ref=ee2c99a"
  source = "../../../modules/inception/azure"
  users  = var.users

  name_prefix = var.name_prefix
}

output "vnet_name" {
  value = module.inception.vnet_name
}
output "bastion_public_ip" {
  value = module.inception.bastion_public_ip
}
