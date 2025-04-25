output "instance_name" {
  value = azurerm_postgresql_flexible_server.instance.name
}

output "private_fqdn" {
  value = azurerm_postgresql_flexible_server.instance.fqdn
}

output "creds" {
  value = {
    for db in local.databases : db => {
      db_name   = db
      user      = module.database[db].user
      password  = module.database[db].password
      conn      = "postgres://${module.database[db].user}:${module.database[db].password}@${azurerm_postgresql_flexible_server.instance.fqdn}:5432/${db}"
      read_conn = local.provision_read_replica ? "postgres://${module.database[db].user}:${module.database[db].password}@${azurerm_postgresql_flexible_server.replica[0].fqdn}:5432/${db}" : ""
      host      = azurerm_postgresql_flexible_server.instance.fqdn
      read_host = local.provision_read_replica ? azurerm_postgresql_flexible_server.replica[0].fqdn : ""
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
    user     = azurerm_postgresql_flexible_server.instance.administrator_login
    password = random_password.admin.result
  }
  sensitive = true
}

output "server_id" {
  value       = azurerm_postgresql_flexible_server.instance.id
  description = "The ID of the PostgreSQL Flexible Server"
}

output "resource_group_name" {
  value = local.resource_group_name
}

# output "vnet" {
#   value = "/subscriptions/${local.subscription_id}/resourceGroups/${local.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${local.virtual_network_name}"
# }

output "source_instance" {
  value = {
    conn = "postgres://${azurerm_postgresql_flexible_server.instance.administrator_login}:${random_password.admin.result}@${azurerm_postgresql_flexible_server.instance.fqdn}:5432/postgres"
  }
  sensitive = true
}

