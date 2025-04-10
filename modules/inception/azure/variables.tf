variable "name_prefix" {
}
variable "network_prefix" {
  default = "10.0"
}

variable "users" {
  type = list(object({
    id        = string
    bastion   = bool
    inception = bool
    platform  = bool
    logs      = bool
  }))
}

locals {
  name_prefix         = var.name_prefix
  network_prefix      = var.network_prefix
  resource_group_name = var.name_prefix

  platform_admins = concat([for user in var.users : user.id if user.platform]) //, ["serviceAccount:${var.inception_sa}"])
  bastion_users   = toset(concat([for user in var.users : user.id if user.bastion], local.platform_admins))
}
