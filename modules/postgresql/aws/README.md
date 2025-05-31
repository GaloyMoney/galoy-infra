# AWS PostgreSQL Module

This module provisions an AWS RDS PostgreSQL instance with private networking, multiple databases, and configurable replication. It's designed to be functionally equivalent to the GCP and Azure PostgreSQL modules while leveraging AWS-specific features.

## Features

- Provisions AWS RDS PostgreSQL instance with configurable resources
- Private networking integration with VPC
- Creates multiple databases with appropriate users and permissions
- Configurable backup retention and maintenance windows
- Read replica support
- Logical replication support
- Detailed logging options
- Database migration support via AWS DMS

## Prerequisites

- An AWS account
- An existing VPC (or permission to create one)
- Terraform 1.0.0+
- Provider requirements:
  - aws >= 5.0.0
  - postgresql 1.24.0

## Usage

### Basic Usage

```hcl
module "postgresql" {
  source = "path/to/modules/postgresql/aws"

  name_prefix = "my-project"
  instance_name = "my-pg-instance"
  region = "us-east-1"

  instance_class = "db.t3.micro"
  engine_version = "14"
  allocated_storage = 20

  databases = ["app", "analytics"]
  user_can_create_db = true

  multi_az = true  # For production
  publicly_accessible = false
  deletion_protection = true
}
```

## Required Input Variables

| Name | Description |
|------|-------------|
| `name_prefix` | Prefix for resource names |
| `instance_name` | Name for the PostgreSQL instance |
| `region` | AWS region |

## Optional Input Variables

| Name | Description | Default |
|------|-------------|---------|
| `instance_class` | RDS instance class | `"db.t3.micro"` |
| `engine_version` | PostgreSQL version | `"14"` |
| `allocated_storage` | Storage in GB | `20` |
| `databases` | List of database names to create | `[]` |
| `user_can_create_db` | Allow user to create databases | `false` |
| `multi_az` | Enable Multi-AZ deployment | `false` |
| `publicly_accessible` | Make instance publicly accessible | `false` |
| `deletion_protection` | Enable deletion protection | `false` |
| `backup_retention_period` | Backup retention period in days | `7` |
| `backup_window` | Preferred backup window | `"03:00-04:00"` |
| `maintenance_window` | Preferred maintenance window | `"Mon:04:00-Mon:05:00"` |
| `replication` | Enable logical replication | `false` |
| `provision_read_replica` | Create a read replica | `false` |
| `max_connections` | Maximum allowed connections | `0` (use AWS default) |
| `enable_detailed_logging` | Enable detailed logging | `false` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_identifier` | The identifier of the RDS instance |
| `instance_endpoint` | The connection endpoint |
| `replica_endpoint` | The read replica endpoint (if enabled) |
| `creds` | Map of credentials for each database (sensitive) |
| `replicator` | Map of replicator credentials (sensitive) |
| `admin_creds` | Admin credentials (sensitive) |

## Differences from GCP/Azure Modules

- Uses AWS RDS instead of Cloud SQL/Azure PostgreSQL Flexible Server
- Networking is handled via VPC security groups and subnet groups
- AWS uses endpoints for connections rather than private IP addresses
- Connection strings use AWS RDS format
- Migration is handled through AWS Database Migration Service (DMS)
- Parameter groups are used for database configuration

## Known Limitations and Considerations

1. **Parameter Handling**: AWS RDS has different parameter configurations than GCP/Azure. Some parameters might not be directly translatable.

2. **Logical Replication**: While supported, logical replication in AWS RDS requires specific parameter group settings.

3. **Network Configuration**: AWS requires proper VPC, subnet groups, and security group configuration.

4. **Migration**: AWS DMS has different requirements and limitations compared to GCP/Azure migration tools.

5. **Monitoring**: CloudWatch is used for monitoring instead of Cloud Operations/Azure Monitor.

## Migration Support

The module includes support for database migration using AWS DMS. To use migration:

1. Set up source and destination instances
2. Configure DMS replication instance
3. Create endpoints for source and target
4. Create and monitor DMS tasks

Example migration configuration is provided in the module. 