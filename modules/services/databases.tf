data "google_sql_database_instance" "postgres" {
  name = local.postgres_instance_name
}
resource "random_password" "sql_root_user_password" {
  length  = 20
  special = false
}

resource "google_sql_user" "root_user" {
  name     = "root_user"
  instance = data.google_sql_database_instance.postgres.name
  password = random_password.sql_root_user_password.result
}

resource "kubernetes_namespace" "pg_access" {
  metadata {
    name = "${local.prefix}-pg-access"
  }
}

provider "postgresql" {
  scheme   = "gcppostgres"
  host     = google_sql_database_instance.postgres.connection_name
  username = google_sql_user.master_user.name
  password = google_sql_user.master_user.password

  # GCP doesn't let you run on Superuser mode https://cloud.google.com/sql/docs/postgres/users#superuser_restrictions
  superuser = false
}

module "dealer_db" {
  source = "./database"

  prefix = "dealer"
  owner  = google_sql_user.root_user.name
}

resource "kubernetes_secret" "dealer_db_credentials" {
  metadata {
    name      = "dealer-db-credentials"
    namespace = kubernetes_namespace.pg_access.metadata.0.name
  }

  data = {
    username = module.dealer_db.username
    password = module.dealer_db.password
    host     = google_sql_database_instance.postgres.private_ip_address
  }
}
