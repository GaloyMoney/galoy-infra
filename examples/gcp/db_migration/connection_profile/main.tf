variable "postgres_host" {}
variable "postgres_user_name" {}
variable "postgres_port" {}
variable "postgres_password" {}
variable "cloud_sql_id" {}

resource "google_database_migration_service_connection_profile" "postgresprofile" {
  location              = "us-east1"
  connection_profile_id = "db-migration-connection-profile"
  display_name          = "db-migration"
  // don't know why I would need a label yet
  labels = {
    foo = "bar"
  }
  postgresql {
    host         = var.postgres_host
    port         = var.postgres_port
    username     = var.postgres_user_name
    password     = var.postgres_password
    cloud_sql_id = var.cloud_sql_id
  }
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.36.0"
    }
  }
}

provider "google" {
  project = "volcano-staging"
  region  = "us-east1"
  # Configuration options
}