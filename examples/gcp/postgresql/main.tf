variable "name_prefix" {}
variable "gcp_project" {}
variable "vpc_name" {}
variable "region" {}
variable "destroyable_postgres" {
  default = false
}

terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
  }
}

module "postgresql_instance" {
  source = "../../../modules/postgresql/gcp/instance"

  instance_name                  = "${var.name_prefix}-pg"
  vpc_name                       = var.vpc_name
  gcp_project                    = var.gcp_project
  region                         = var.region
  destroyable                    = var.destroyable_postgres
  highly_available               = false
  tier                           = "db-custom-1-3840"
  provision_read_replica         = true
  backup_enabled                 = true
  point_in_time_recovery_enabled = true
}

provider "postgresql" {
  host     = module.postgresql_instance.private_ip
  port     = 5432
  username = module.postgresql_instance.admin_user
  password = module.postgresql_instance.admin_password

  # GCP doesn't allow PostgreSQL superuser mode:
  # https://cloud.google.com/sql/docs/postgres/users#superuser_restrictions
  superuser = false
}

module "postgresql_database" {
  source = "../../../modules/postgresql/gcp/database"

  db_name         = "test"
  admin_user_name = module.postgresql_instance.admin_user
  user_name       = "test-user"
  readonly_users  = []

  depends_on = [module.postgresql_instance]
}

output "database_user" {
  value = module.postgresql_database.user
}

output "database_password" {
  value     = module.postgresql_database.password
  sensitive = true
}
