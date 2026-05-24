variable "host" {}
variable "port" {}
variable "username" {}
variable "password" {
  sensitive = true
}

provider "postgresql" {
  host     = var.host
  port     = var.port
  username = var.username
  password = var.password

  # GCP doesn't allow PostgreSQL superuser mode:
  # https://cloud.google.com/sql/docs/postgres/users#superuser_restrictions
  superuser = false
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
  }
}
