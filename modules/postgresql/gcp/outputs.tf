output "instance_name" {
  value = google_sql_database_instance.instance.name
}

output "private_ip" {
  value = google_sql_database_instance.instance.private_ip_address
}

output "creds" {
  value = {
    for db in local.databases : db => {
      db_name   = db
      user      = module.database[db].user
      password  = module.database[db].password
      conn      = "postgres://${module.database[db].user}:${module.database[db].password}@${google_sql_database_instance.instance.private_ip_address}:5432/${db}"
      read_conn = local.provision_read_replica ? "postgres://${module.database[db].user}:${module.database[db].password}@${google_sql_database_instance.replica[0].private_ip_address}:5432/${db}" : ""
      host      = google_sql_database_instance.instance.private_ip_address
      read_host = local.provision_read_replica ? google_sql_database_instance.replica[0].private_ip_address : ""
    }
  }
  sensitive = true
}

output "replicator" {
  value = local.replication ? {
    for db in local.databases : db => {
      password = module.database[db].replicator_password
    }
  } : {}
  sensitive = true
}

output "admin-creds" {
  value = {
    user     = google_sql_user.admin.name
    password = random_password.admin.result
  }
}

output "connection_profile_credentials" {
  value = {
    source_connection_profile_id      = module.migration.source_connection_profile_id
    destination_connection_profile_id = module.migration.destination_connection_profile_id
  }
}