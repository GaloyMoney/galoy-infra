provider "azurerm" {
  features {}
}

variable "name_prefix" {}


# Basic PostgreSQL Instance
module "postgresql" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/azure?ref=80052e7"
  # source = "../../../modules/postgresql/azure"

  instance_name       = "${var.name_prefix}-pg"
  resource_group_name = var.name_prefix
  user_can_create_db  = true
  databases           = ["test"]
}
