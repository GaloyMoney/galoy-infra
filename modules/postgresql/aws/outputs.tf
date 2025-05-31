output "instance_name" {
  value = aws_db_instance.instance.identifier
}

output "private_endpoint" {
  value = aws_db_instance.instance.endpoint
}

output "creds" {
  value = var.create_databases ? {
    for db in local.databases : db => {
      user      = module.database[index(local.databases, db)].user
      password  = module.database[index(local.databases, db)].password
      conn      = "postgres://${module.database[index(local.databases, db)].user}:${module.database[index(local.databases, db)].password}@${aws_db_instance.instance.endpoint}/${db}"
    }
  } : {}
  sensitive = true
}

output "replicator_creds" {
  value = var.create_databases && local.replication ? {
    for db in local.databases : db => {
      user      = "${db}-replicator"
      password  = module.database[index(local.databases, db)].replicator_password
    }
  } : {}
  sensitive = true
}

output "admin-creds" {
  value = {
    user     = aws_db_instance.instance.username
    password = random_password.admin.result
  }
  sensitive = true
}

output "connection_profile_credentials" {
  value = local.prep_upgrade_as_source_db ? {
    source_connection_profile_id      = module.migration[0].source_connection_profile_id
    destination_connection_profile_id = module.migration[0].destination_connection_profile_id
  } : {}
}

output "vpc" {
  value = data.aws_vpc.vpc.id
}

output "migration_destination_instance" {
  value = local.prep_upgrade_as_source_db ? {
    conn = "postgres://postgres:${module.migration[0].postgres_user_password}@${module.migration[0].destination_instance_endpoint}/postgres"
  } : {}
}

output "source_instance" {
  value = {
    conn = "postgres://${aws_db_instance.instance.username}:${random_password.admin.result}@${aws_db_instance.instance.endpoint}/postgres"
  }
}

output "endpoint" {
  description = "The endpoint of the PostgreSQL instance"
  value       = aws_db_instance.instance.endpoint
}

output "port" {
  description = "The port of the PostgreSQL instance"
  value       = aws_db_instance.instance.port
}

output "database_name" {
  description = "The name of the default database"
  value       = aws_db_instance.instance.db_name
}

output "username" {
  description = "The master username for the database"
  value       = aws_db_instance.instance.username
}

output "password" {
  description = "The master password for the database"
  value       = random_password.admin.result
  sensitive   = true
}

output "postgresql_endpoint" {
  value = aws_db_instance.instance.endpoint
}

output "postgresql_address" {
  value = aws_db_instance.instance.address
}

output "postgresql_username" {
  value = aws_db_instance.instance.username
}

output "postgresql_password" {
  value = random_password.admin.result
  sensitive = true
} 