variable "gcp_project" {}
variable "vpc_name" {}
variable "instance_name" {}

variable "region" {}

variable "destroyable" {}

variable "highly_available" {}

variable "tier" {}

variable "enable_detailed_logging" {
  description = "Enable detailed logging for the PostgreSQL instance"
  type        = bool
  default     = false
}

variable "database_version" {
  default = "POSTGRES_18"
}

variable "provision_read_replica" {
  description = "Provision read replica"
  type        = bool
  default     = false
}

variable "backup_enabled" {
  description = "Enable automated backups for the primary instance"
  type        = bool
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery for the primary instance"
  type        = bool
}

variable "query_insights_enabled" {
  description = "Enable query insights for the PostgreSQL instance"
  type        = bool
  default     = true
}

locals {
  gcp_project                    = var.gcp_project
  vpc_name                       = var.vpc_name
  region                         = var.region
  instance_name                  = var.instance_name
  database_version               = var.database_version
  destroyable                    = var.destroyable
  highly_available               = var.highly_available
  tier                           = var.tier
  provision_read_replica         = var.provision_read_replica
  backup_enabled                 = var.backup_enabled
  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
  database_port                  = 5432
  query_insights_enabled         = var.query_insights_enabled
}
