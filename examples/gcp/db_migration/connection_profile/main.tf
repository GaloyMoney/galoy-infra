terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.36.0"
    }
  }
}

provider "google" {
  project = "volcano-staging"
  region = "us-east1"
  # Configuration options
}

resource "google_database_migration_service_connection_profile" "postgresprofile" {
  location = "us-east1"
  connection_profile_id = "db-migration-connection-profile"
  display_name = "db-migration"
  labels = { 
    foo = "bar" 
  }
  postgresql {
    host = google_sql_database_instance.postgresqldb.ip_address.0.ip_address
    port = 5432
    username = google_sql_user.sqldb_user.name
    password = google_sql_user.sqldb_user.password
    ssl {
      client_key = google_sql_ssl_cert.sql_client_cert.private_key
      client_certificate = google_sql_ssl_cert.sql_client_cert.cert
      ca_certificate = google_sql_ssl_cert.sql_client_cert.server_ca_cert
    }
    cloud_sql_id = "my-database"
  }
  depends_on = [google_sql_user.sqldb_user]
}