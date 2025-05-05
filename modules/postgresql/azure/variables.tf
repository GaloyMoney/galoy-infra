variable "resource_group_name" {}
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
variable "databases" {
  type        = list(string)
  description = "List of database names to create"
}
variable "replication" {
  description = "Enable logical replication for the PostgreSQL instance"
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

locals {
  resource_group_name          = var.resource_group_name
  virtual_network_name         = "${local.resource_group_name}-vnet"
  subnet_name                  = "${local.resource_group_name}-postgres"
  region                       = var.region
  instance_name                = var.instance_name
  postgresql_version           = var.postgresql_version
  sku_name                     = var.sku_name
  storage_mb                   = var.storage_mb
  max_connections              = var.max_connections
  databases                    = var.databases
  replication                  = var.replication
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  database_port                = 5432
}

