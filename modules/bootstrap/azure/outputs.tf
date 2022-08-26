output "tf_state_storage_blob_name" {
  value = azurerm_storage_blob.tf_state.name
}
output "tf_state_storage_container" {
  value = azurerm_storage_container.bootstrap.name
}
output "tf_state_storage_location" {
  value = azurerm_storage_account.bootstrap.location
}
output "tf_state_storage_account" {
  value = azurerm_storage_account.bootstrap.name
}

output "resource_group" {
  value = azurerm_resource_group.bootstrap.name
}
output "application_id" {
  value = azuread_application.inception.application_id
}
output "client_secret" {
  value     = azuread_application_password.inception_app_password.value
  sensitive = true
}
output "tenant_id" {
  value = local.tenant_id
}
output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}
output "name_prefix" {
  value = local.name_prefix
}
output "tf_state_storage_blob_id" {
  value = azurerm_storage_blob.tf_state.id
}
output "tf_state_storage_container_id" {
  value = azurerm_storage_container.bootstrap.id
}
output "tf_state_storage_account_id" {
  value = azurerm_storage_account.bootstrap.id
}
output "tf_state_access_key" {
  value     = data.external.access_key.result
  sensitive = true
}
