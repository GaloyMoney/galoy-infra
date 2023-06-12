variable "gcp_project" {}
variable "vpc_name" {}
variable "instance_name" {}
variable "region" {
  default = "us-east1"
}
variable "destroyable" {
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
  default     = true
}

locals {
  gcp_project       = var.gcp_project
  vpc_name          = var.vpc_name
  region            = var.region
  instance_name     = var.instance_name
  destroyable       = var.destroyable
  highly_available  = var.highly_available
  tier              = var.tier
  max_connections   = var.max_connections
  databases         = var.databases
  big_query_viewers = var.big_query_viewers
  replication       = var.replication
}
