variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "create_databases" {
  description = "Whether to create the databases"
  type        = bool
  default     = false
}

variable "bastion_instance_id" {
  description = "ID of the bastion instance for port forwarding"
  type        = string
}

module "postgresql" {
  source = "../../../modules/postgresql/aws"

  name_prefix = var.name_prefix
  instance_name = "${var.name_prefix}-pg"
  region = var.region
  bastion_instance_id = var.bastion_instance_id

  instance_class = "db.t3.micro"
  database_version = "14"
  databases = ["test"]
  create_databases = true

  highly_available = true
  destroyable = true  
  skip_final_snapshot = true  

  replication = false
  provision_read_replica = false

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

resource "random_password" "postgres_password" {
  length  = 20
  special = false
} 

output "postgresql_endpoint" {
  value = module.postgresql.endpoint
}

output "postgresql_port" {
  value = module.postgresql.port
}

output "postgresql_username" {
  value     = module.postgresql.username
  sensitive = true
}

output "postgresql_password" {
  value     = module.postgresql.password
  sensitive = true
} 
