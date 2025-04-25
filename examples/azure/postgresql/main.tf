provider "azurerm" {
  features {}
}

variable "name_prefix" {}
# variable "resource_group_name" {}
# variable "virtual_network_name" {}
# variable "subnet_name" {
#   default = null
# }
variable "destroyable_postgres" {
  default = false
}

# locals {
#   resource_group_name = var.resource_group_name != null ? var.resource_group_name : azurerm_resource_group.rg[0].name
# }

# Basic PostgreSQL Instance
module "postgresql" {
  source = "../../../modules/postgresql/azure"

  instance_name        = "${var.name_prefix}-pg"
  resource_group_name  = var.name_prefix
  virtual_network_name = "${var.name_prefix}-vnet"
  subnet_name          = "${var.name_prefix}-dmz"
  destroyable          = var.destroyable_postgres
  user_can_create_db   = true
  databases            = ["test"]
}

# PostgreSQL with High Availability and Read Replica
# module "postgresql_ha" {
#   source = "../../../modules/postgresql/azure"

#   instance_name          = "${var.name_prefix}-pg-ha"
#   subscription_id        = var.subscription_id
#   resource_group_name    = local.resource_group_name
#   virtual_network_name   = var.virtual_network_name
#   subnet_name            = var.subnet_name
#   destroyable            = var.destroyable_postgres
#   user_can_create_db     = true
#   databases              = ["test", "app"]
#   highly_available       = true
#   replication            = true
#   provision_read_replica = true
#   sku_name               = "GP_Standard_D4s_v3"  # More powerful SKU for HA
#   storage_mb             = 65536                 # 64GB storage
# }

# # PostgreSQL with Migration Source Configuration
# module "postgresql_migration_source" {
#   source = "../../../modules/postgresql/azure"

#   instance_name             = "${var.name_prefix}-pg-source"
#   subscription_id           = var.subscription_id
#   resource_group_name       = local.resource_group_name
#   virtual_network_name      = var.virtual_network_name
#   subnet_name               = var.subnet_name
#   destroyable               = var.destroyable_postgres
#   user_can_create_db        = true
#   databases                 = ["test"]
#   postgresql_version        = "14"
#   replication               = true
#   prep_upgrade_as_source_db = true
# }

# # PostgreSQL as Migration Destination
# module "postgresql_migration_destination" {
#   source = "../../../modules/postgresql/azure"

#   instance_name          = "${var.name_prefix}-pg-dest"
#   subscription_id        = var.subscription_id
#   resource_group_name    = local.resource_group_name
#   virtual_network_name   = var.virtual_network_name
#   subnet_name            = var.subnet_name
#   destroyable            = var.destroyable_postgres
#   databases              = []
#   postgresql_version     = "15"
#   pre_promotion          = true
# }

# Output connection information
output "postgresql_connection" {
  value     = module.postgresql.source_instance.conn
  sensitive = true
}

# output "postgresql_ha_connection" {
#   value     = module.postgresql_ha.source_instance.conn
#   sensitive = true
# }

output "postgresql_test_creds" {
  value     = module.postgresql.creds["test"]
  sensitive = true
}

