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
  value = local.prep_upgrade_as_source_db ? {
    source_connection_profile_id      = module.migration[0].source_connection_profile_id
    destination_connection_profile_id = module.migration[0].destination_connection_profile_id
  } : {}
}

output "vpc" {
  value = "projects/${local.gcp_project}/global/networks/${local.vpc_name}"
}

output "migration_destination_instance" {
  value = local.prep_upgrade_as_source_db ? {
    conn = "postgres://postgres:${module.migration[0].postgres_user_password}@${module.migration[0].destination_instance_private_ip_address}:5432/postgres"
  } : {}
}

output "source_instance" {
  value = {
    conn = "postgres://${google_sql_user.admin.name}:${random_password.admin.result}@${google_sql_database_instance.instance.private_ip_address}:5432/postgres"
  }
}
output "migration_sql_command" {
  value = local.prep_upgrade_as_source_db ? {
    sql_command = "psql postgres://postgres:${module.migration[0].postgres_user_password}@${module.migration[0].destination_instance_private_ip_address}:5432/postgres -c \"ALTER ROLE cloudsqlexternalsync RENAME TO \\\"${google_sql_user.admin.name}\\\"; ALTER ROLE \\\"${google_sql_user.admin.name}\\\" PASSWORD '${random_password.admin.result}';\""
  } : {}
}
