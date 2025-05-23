variable "gcp_project" {}
variable "vpc_name" {}
variable "instance_name" {}
variable "region" {
  default = "us-east1"
}
variable "destroyable" {
  default = false
}
variable "user_can_create_db" {
  default = false
}
variable "highly_available" {
  default = true
}
variable "tier" {
  default = "db-custom-1-3840"
}
variable "max_connections" { default = 0 }
variable "enable_detailed_logging" {
  description = "Enable detailed logging for the PostgreSQL instance"
  type        = bool
  default     = false
}
variable "database_version" {
  default = "POSTGRES_17"
}
variable "destination_database_version" {
  default = "POSTGRES_17"
}
variable "big_query_viewers" {
  default = []
  type    = list(string)
}
variable "databases" {
  type = list(string)
}
variable "replication" {
  description = "Enable logical replication for the PostgreSQL instance"
  type        = bool
  default     = false
}
variable "provision_read_replica" {
  description = "Provision read replica"
  type        = bool
  default     = false
}
variable "big_query_connection_location" {
  default = "US"
}

variable "prep_upgrade_as_source_db" {
  description = "Configure source destination instance to be upgradable via Database Migration Service"
  type        = bool
  default     = false
}

variable "pre_promotion" {
  description = "Configure the destination instance which becomes the source after the terraform to act nicely with the migration service"
  type        = bool
  default     = false
}

locals {
  gcp_project                   = var.gcp_project
  vpc_name                      = var.vpc_name
  region                        = var.region
  instance_name                 = var.instance_name
  database_version              = var.database_version
  destination_database_version  = var.destination_database_version
  destroyable                   = var.destroyable
  highly_available              = var.highly_available
  tier                          = var.tier
  max_connections               = var.max_connections
  databases                     = var.databases
  migration_databases           = concat(var.databases, ["postgres"])
  big_query_viewers             = var.big_query_viewers
  replication                   = var.replication
  provision_read_replica        = var.provision_read_replica
  big_query_connection_location = var.big_query_connection_location
  prep_upgrade_as_source_db     = var.prep_upgrade_as_source_db
  pre_promotion                 = var.pre_promotion
  database_port                 = 5432
}
