variable "name_prefix" {
  description = "Prefix to be used in the naming of some of the created resources"
  type        = string
}

variable "region" {
  type = string
}

variable "instance_name" {
  description = "Name for the PostgreSQL instance"
  type        = string
}

variable "database_version" {
  description = "PostgreSQL version to use"
  type        = string
  default     = "14"
}

variable "destination_database_version" {
  description = "PostgreSQL version to use for destination instance during migration"
  type        = string
  default     = ""
}

variable "destroyable" {
  description = "Whether the database can be destroyed"
  type        = bool
  default     = false
}

variable "highly_available" {
  description = "Whether to enable high availability (Multi-AZ)"
  type        = bool
  default     = false
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "max_connections" {
  description = "Maximum number of database connections"
  type        = number
  default     = 0
}

variable "databases" {
  description = "List of databases to create"
  type        = list(string)
  default     = []
}

variable "replication" {
  description = "Whether to enable logical replication"
  type        = bool
  default     = false
}

variable "provision_read_replica" {
  description = "Whether to provision a read replica"
  type        = bool
  default     = false
}

variable "prep_upgrade_as_source_db" {
  description = "Whether to prepare this instance as a source for upgrade"
  type        = bool
  default     = false
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when destroying the database"
  type        = bool
  default     = true  # Default to true for easier cleanup
}

variable "publicly_accessible" {
  description = "Whether the DB should be publicly accessible"
  type        = bool
  default     = false
}

variable "enable_detailed_logging" {
  description = "Whether to enable detailed logging"
  type        = bool
  default     = false
}

variable "user_can_create_db" {
  description = "Whether the user can create databases"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "migration_databases" {
  description = "List of databases to migrate"
  type        = list(string)
  default     = []
}

variable "pre_promotion" {
  description = "Configure the destination instance which becomes the source after the terraform to act nicely with the migration service"
  type        = bool
  default     = false
}

variable "create_databases" {
  description = "Whether to create databases and roles"
  type        = bool
  default     = false
}

data "aws_region" "current" {}

locals {
  name_prefix                   = var.name_prefix
  instance_name                = coalesce(var.instance_name, "${local.name_prefix}-pg")
  database_port                = 5432
  database_version             = var.database_version
  destination_database_version = var.destination_database_version
  instance_class              = var.instance_class
  highly_available            = var.highly_available
  destroyable                 = var.destroyable
  replication                 = var.replication && !var.destroyable && !var.pre_promotion
  provision_read_replica      = var.provision_read_replica && !var.destroyable && !var.pre_promotion
  prep_upgrade_as_source_db   = var.prep_upgrade_as_source_db && !var.destroyable
  databases                   = var.databases
  migration_databases         = concat(var.databases, ["postgres"])  # Include postgres db like GCP
  max_connections             = var.max_connections
  region                      = data.aws_region.current.name
  subnet_number_offset        = 80  # Start from a safe offset
  pre_promotion               = var.pre_promotion
  
  # Ensure we have proper subnet spacing
  subnet_spacing = 2  # Number of subnets per instance
  primary_subnet_offset = local.subnet_number_offset
  source_subnet_offset  = local.subnet_number_offset + local.subnet_spacing
  dest_subnet_offset    = local.subnet_number_offset + (local.subnet_spacing * 2)
} 