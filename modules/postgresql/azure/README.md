# Azure PostgreSQL Module

This module provisions an Azure Database for PostgreSQL Flexible Server with private networking, multiple databases, and configurable replication. It's designed to be functionally equivalent to the GCP PostgreSQL module while adapting to Azure's architecture and features.

## Features

- Provisions Azure PostgreSQL Flexible Server with configurable resources
- Private networking integration with existing VNet or auto-created subnet
- Creates multiple databases with appropriate users and permissions
- Configurable backup retention and geo-redundancy
- Logical replication support
- Detailed logging options

## Prerequisites

- An Azure subscription
- A Resource Group
- An existing Virtual Network (or permission to create subnets)
- Terraform 1.0.0+
- Provider requirements:
  - azurerm >= 3.0.0
  - postgresql 1.24.0

## Usage

### Basic Usage

```hcl
module "postgresql" {
  source = "path/to/modules/postgresql/azure"

  instance_name        = "my-pg-instance"
  subscription_id      = "your-subscription-id"
  resource_group_name  = "your-resource-group"
  virtual_network_name = "your-vnet-name"

  databases            = ["app", "analytics"]
  postgresql_version   = "14"
  sku_name             = "GP_Standard_D2s_v3"
  storage_mb           = 32768
}
```

## Required Input Variables

| Name | Description |
|------|-------------|
| `subscription_id` | Azure subscription ID |
| `resource_group_name` | Azure resource group name |
| `virtual_network_name` | Name of the virtual network |
| `instance_name` | Name for the PostgreSQL instance |
| `databases` | List of database names to create |

## Optional Input Variables

| Name | Description | Default |
|------|-------------|---------|
| `subnet_name` | Name of subnet to use (will create one if null) | `null` |
| `region` | Azure region | `"eastus"` |
| `user_can_create_db` | Allow user to create databases | `false` |
| `sku_name` | SKU name for the server | `"GP_Standard_D2s_v3"` |
| `storage_mb` | Storage in MB | `32768` |
| `max_connections` | Maximum allowed connections | `0` (use Azure default) |
| `enable_detailed_logging` | Enable detailed logging | `false` |
| `postgresql_version` | PostgreSQL version | `"14"` |
| `replication` | Enable logical replication | `false` |
| `backup_retention_days` | Backup retention period in days | `7` |
| `geo_redundant_backup_enabled` | Enable geo-redundant backups | `false` |
| `private_dns_zone_id` | ID of existing private DNS zone | `null` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_name` | The name of the PostgreSQL instance |
| `private_fqdn` | The private FQDN of the PostgreSQL instance |
| `creds` | Map of credentials for each database (sensitive) |
| `replicator` | Map of replicator credentials (sensitive) |
| `admin-creds` | Admin credentials (sensitive) |
| `server_id` | The ID of the PostgreSQL Flexible Server |
| `resource_group_name` | The resource group name |
| `vnet` | The virtual network resource path |

## Differences from GCP Module

- Uses Azure PostgreSQL Flexible Server instead of Cloud SQL
- Networking is handled via delegated subnets for Flexible Server
- Azure uses FQDN for connections rather than private IP addresses
- Connection strings use Azure PostgreSQL format
- BigQuery integration is not available (Azure has Azure Synapse Analytics or Azure Data Factory as alternatives)
- Database parameter configuration is handled via specific Azure resources

## Known Limitations and Considerations

1. **Parameter Handling**: Azure PostgreSQL has different parameter configurations than GCP. Some parameters might not be directly translatable.

2. **Logical Replication**: While supported, logical replication in Azure PostgreSQL may have different configuration requirements than GCP.

3. **Network Configuration**: Azure requires a dedicated subnet with proper delegation for PostgreSQL Flexible Server.

4. **Firewall Rules**: Azure PostgreSQL Flexible Server uses different firewall concepts than GCP Cloud SQL.

## Maintenance and Scaling

To modify the PostgreSQL instance after creation:
- Update storage: Change the `storage_mb` variable
- Scale up/down: Modify the `sku_name` variable
- Add databases: Append to the `databases` list

Note that some changes may cause instance restarts, which could result in downtime.

