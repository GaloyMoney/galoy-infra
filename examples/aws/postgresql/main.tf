# Primary PostgreSQL instance
module "postgresql" {
  source = "../../../modules/postgresql/aws"

  name_prefix = var.name_prefix
  instance_name = "${var.name_prefix}-pg"
  region = var.region

  instance_class = "db.t3.micro"
  database_version = "14"
  destination_database_version = "16"
  databases = ["test"]
  create_databases = true

  # Safety settings
  highly_available = false
  destroyable = true  # Set to true for example purposes
  skip_final_snapshot = true  # For easier cleanup in example

  # Disable replication features for simpler example
  replication = false
  provision_read_replica = false
  prep_upgrade_as_source_db = false

  allocated_storage = 20
  backup_retention_period = 7
  backup_window = "03:00-04:00"
  maintenance_window = "Mon:04:00-Mon:05:00"
  publicly_accessible = false
  user_can_create_db = false
  max_connections = 100

  enable_detailed_logging = true

  tags = {
    Environment = "example"
    Purpose     = "testing"
  }
}

# Comment out migration modules by default to avoid resource conflicts
# Uncomment and modify as needed for testing migration scenarios
/*
module "postgresql_migration_source" {
  source = "../../../modules/postgresql/aws"

  name_prefix = var.name_prefix
  instance_name = "${var.name_prefix}-pg-source"  # Distinct name
  region = var.region

  instance_class = "db.t3.micro"
  database_version = "14"
  destination_database_version = "16"
  databases = ["test"]

  highly_available = false
  user_can_create_db = true
  destroyable = true  # Set to true for example purposes
  skip_final_snapshot = true

  replication = true
  provision_read_replica = false  # Avoid extra resources
  prep_upgrade_as_source_db = true

  allocated_storage = 20
  backup_retention_period = 7
  backup_window = "03:00-04:00"
  maintenance_window = "Mon:04:00-Mon:05:00"
  publicly_accessible = false
  max_connections = 100

  enable_detailed_logging = true

  tags = {
    Environment = "example"
    Purpose     = "migration-source"
  }
}

module "postgresql_migration_destination" {
  source = "../../../modules/postgresql/aws"

  name_prefix = var.name_prefix
  instance_name = "${var.name_prefix}-pg-dest"  # Distinct name
  region = var.region

  instance_class = "db.t3.micro"
  database_version = "15"
  destination_database_version = "16"
  databases = []

  highly_available = false
  user_can_create_db = true
  destroyable = true  # Set to true for example purposes
  skip_final_snapshot = true

  replication = false
  provision_read_replica = false
  prep_upgrade_as_source_db = false

  allocated_storage = 20
  backup_retention_period = 7
  backup_window = "03:00-04:00"
  maintenance_window = "Mon:04:00-Mon:05:00"
  publicly_accessible = false
  max_connections = 100

  enable_detailed_logging = true

  tags = {
    Environment = "example"
    Purpose     = "migration-destination"
  }
}
*/

resource "random_password" "postgres_password" {
  length  = 20
  special = false
} 