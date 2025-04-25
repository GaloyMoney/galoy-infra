# variable "subscription_id" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "subnet_name" {}
variable "instance_name" {}
variable "region" {
  default = "eastus"
}
variable "user_can_create_db" {
  default = false
}
variable "sku_name" {
  default     = "GP_Standard_D2s_v3"
  description = "The SKU name for the PostgreSQL Flexible Server"
}
variable "storage_mb" {
  default     = 32768
  description = "The storage size for the PostgreSQL Flexible Server in MB"
}
variable "max_connections" {
  default     = 0
  description = "Maximum allowed connections. 0 means use Azure default."
}
variable "enable_detailed_logging" {
  description = "Enable detailed logging for the PostgreSQL instance"
  type        = bool
  default     = false
}
variable "postgresql_version" {
  default     = "14"
  description = "The version of PostgreSQL to use"
}
variable "destination_postgresql_version" {
  default     = "15"
  description = "The version of PostgreSQL to use for migration destination"
}
variable "databases" {
  type        = list(string)
  description = "List of database names to create"
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
variable "backup_retention_days" {
  description = "Backup retention days for the server (between 7 and 35)"
  type        = number
  default     = 7
}
variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}
variable "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone for private endpoint"
  type        = string
  default     = null
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
  # subscription_id                = var.subscription_id
  resource_group_name            = var.resource_group_name
  virtual_network_name           = var.virtual_network_name
  subnet_name                    = var.subnet_name
  region                         = var.region
  instance_name                  = var.instance_name
  postgresql_version             = var.postgresql_version
  destination_postgresql_version = var.destination_postgresql_version
  sku_name                       = var.sku_name
  storage_mb                     = var.storage_mb
  max_connections                = var.max_connections
  databases                      = var.databases
  migration_databases            = concat(var.databases, ["postgres"])
  replication                    = var.replication
  provision_read_replica         = var.provision_read_replica
  prep_upgrade_as_source_db      = var.prep_upgrade_as_source_db
  pre_promotion                  = var.pre_promotion
  backup_retention_days          = var.backup_retention_days
  geo_redundant_backup_enabled   = var.geo_redundant_backup_enabled
  database_port                  = 5432
}

