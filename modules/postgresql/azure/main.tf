data "azurerm_virtual_network" "vnet" {
  name                = local.virtual_network_name
  resource_group_name = local.resource_group_name
}

data "azurerm_subnet" "subnet" {
  count                = var.delegated_subnet_name != null ? 1 : 0
  name                 = local.delegated_subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = local.resource_group_name
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "random_password" "admin" {
  length  = 20
  special = false
}

resource "azurerm_subnet" "postgres_subnet" {
  count                = var.delegated_subnet_name == null ? 1 : 0
  name                 = local.delegated_subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(data.azurerm_virtual_network.vnet.address_space[0], 8, 10)]

  delegation {
    name = "fs"

    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = local.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "${local.instance_name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = local.resource_group_name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

locals {
  private_dns_zone_id = var.private_dns_zone_id != null ? var.private_dns_zone_id : azurerm_private_dns_zone.postgres.id
}

resource "azurerm_postgresql_flexible_server" "instance" {
  name                          = "${local.instance_name}-${random_id.db_name_suffix.hex}"
  resource_group_name           = local.resource_group_name
  location                      = local.region
  version                       = local.postgresql_version
  public_network_access_enabled = false
  private_dns_zone_id           = local.private_dns_zone_id
  administrator_login           = replace("${local.instance_name}pgadmin", "-", "")
  administrator_password        = random_password.admin.result
  zone                          = 1

  storage_mb = local.storage_mb
  sku_name   = local.sku_name

  backup_retention_days        = local.backup_retention_days
  geo_redundant_backup_enabled = local.geo_redundant_backup_enabled
}

# Configure max connections if specified
resource "azurerm_postgresql_flexible_server_configuration" "max_connections" {
  count     = local.max_connections > 0 ? 1 : 0
  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.instance.id
  value     = tostring(local.max_connections)
}

# Configure detailed logging if enabled
resource "azurerm_postgresql_flexible_server_configuration" "log_statement" {
  count     = var.enable_detailed_logging ? 1 : 0
  name      = "log_statement"
  server_id = azurerm_postgresql_flexible_server.instance.id
  value     = "all"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_lock_waits" {
  count     = var.enable_detailed_logging ? 1 : 0
  name      = "log_lock_waits"
  server_id = azurerm_postgresql_flexible_server.instance.id
  value     = "on"
}

# Enable logical replication if specified
resource "azurerm_postgresql_flexible_server_configuration" "logical_decoding" {
  count     = local.replication ? 1 : 0
  name      = "wal_level"
  server_id = azurerm_postgresql_flexible_server.instance.id
  value     = "logical"
}

module "database" {
  for_each = toset(local.databases)
  source   = "./database"

  resource_group_name = local.resource_group_name
  db_name             = each.value
  admin_user_name     = azurerm_postgresql_flexible_server.instance.administrator_login
  admin_password      = random_password.admin.result
  user_name           = "${each.value}-user"
  user_can_create_db  = var.user_can_create_db
  pg_server_name      = azurerm_postgresql_flexible_server.instance.name
  server_fqdn         = azurerm_postgresql_flexible_server.instance.fqdn
  replication         = local.replication
}

provider "postgresql" {
  host      = azurerm_postgresql_flexible_server.instance.fqdn
  port      = local.database_port
  username  = azurerm_postgresql_flexible_server.instance.administrator_login
  password  = random_password.admin.result
  sslmode   = "require"
  superuser = false
}

# Add network security group for the PostgreSQL subnet
resource "azurerm_network_security_group" "postgres" {
  name                = "${local.instance_name}-nsg"
  location            = local.region
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "allow-postgres"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

# Associate the NSG with the PostgreSQL subnet
resource "azurerm_subnet_network_security_group_association" "postgres" {
  subnet_id                 = var.delegated_subnet_name == null ? azurerm_subnet.postgres_subnet.id : data.azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.postgres.id
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
  }
}

