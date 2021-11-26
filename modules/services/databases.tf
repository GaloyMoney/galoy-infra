# data "google_sql_database_instance" "postgres" {
#   name    = local.postgres_instance_name
#   project = local.gcp_project
# }

# resource "random_password" "sql_root_user_password" {
#   length  = 20
#   special = false
# }

# resource "google_sql_user" "root_user" {
#   name     = "root_user"
#   instance = data.google_sql_database_instance.postgres.name
#   password = random_password.sql_root_user_password.result
#   project  = local.gcp_project
# }

resource "kubernetes_namespace" "pg_access" {
  metadata {
    name = "${local.name_prefix}-pg-access"
  }
}

# module "dealer_db" {
#   source = "./database"

#   prefix      = "dealer"
#   owner       = google_sql_user.root_user.name
#   pg_host     = data.google_sql_database_instance.postgres.private_ip_address
#   pg_username = google_sql_user.root_user.name
#   pg_password = google_sql_user.root_user.password
# }

# resource "kubernetes_secret" "dealer_db_credentials" {
#   metadata {
#     name      = "dealer-db-credentials"
#     namespace = kubernetes_namespace.pg_access.metadata.0.name
#   }

#   data = {
#     username = module.dealer_db.username
#     password = module.dealer_db.password
#     host     = data.google_sql_database_instance.postgres.private_ip_address
#   }
# }
