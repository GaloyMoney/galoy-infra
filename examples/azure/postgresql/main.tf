provider "azurerm" {
  features {}
}

variable "name_prefix" {}


# Basic PostgreSQL Instance
module "postgresql" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/azure?ref=63a514a"
  # source = "../../../modules/postgresql/azure"

  instance_name       = "${var.name_prefix}-pg"
  resource_group_name = var.name_prefix
  user_can_create_db  = true
  databases           = ["test"]
}
