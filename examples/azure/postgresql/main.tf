provider "azurerm" {
  features {}
}

variable "name_prefix" {}


# Basic PostgreSQL Instance
module "postgresql" {
  source = "../../../modules/postgresql/azure"

  instance_name        = "${var.name_prefix}-pg"
  resource_group_name  = var.name_prefix
  virtual_network_name = "${var.name_prefix}-vnet"
  subnet_name          = "${var.name_prefix}-dmz"
  user_can_create_db   = true
  databases            = ["test"]
}

# Output connection information
output "postgresql_connection" {
  value     = module.postgresql.source_instance.conn
  sensitive = true
}

output "postgresql_test_creds" {
  value     = module.postgresql.creds["test"]
  sensitive = true
}

