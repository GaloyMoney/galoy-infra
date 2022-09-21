variable "project" {}
variable "vpc_id" {}
variable "region" {}
variable "instance_name" {}
variable "destroyable_postgres" {}
variable "highly_available" {}
variable "postgres_tier" {}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  name = "${var.instance_name}-${random_id.db_name_suffix.hex}"

  project             = var.project
  database_version    = "POSTGRES_14"
  region              = var.region
  deletion_protection = !var.destroyable_postgres

  settings {
    tier              = var.postgres_tier
    availability_type = var.highly_available ? "REGIONAL" : "ZONAL"

    database_flags {
      name  = "max_connections"
      value = 100
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
    }
  }
}

resource "random_password" "admin" {
  length  = 20
  special = false
}

resource "google_sql_user" "admin" {
  name     = "${var.instance_name}-admin"
  instance = google_sql_database_instance.instance.name
  password = random_password.admin.result
  project  = var.project
}

output "admin_username" {
  value = google_sql_user.admin.name
}
output "admin_password" {
  value = random_password.admin.result
}
output "private_ip" {
  value = google_sql_database_instance.instance.private_ip_address
}

output "connection_name" {
  value = google_sql_database_instance.instance.connection_name
}
