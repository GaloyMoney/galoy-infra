output "tf_state_storage_blob_name" {
  value = azurerm_storage_blob.tf_state.name
}
output "tf_state_storage_container" {
  value = azurerm_storage_container.tf_state.name
}
output "tf_state_storage_location" {
  value = azurerm_storage_account.tf_state.location
}
output "tf_state_storage_account" {
  value = azurerm_storage_account.tf_state.name
}

output "resource_group" {
  value = azurerm_resource_group.resource_group.name
}
output "client_id" {
  value = azuread_application.inception.client_id
}
output "client_secret" {
  value     = azuread_application_password.inception_app_password.value
  sensitive = true
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
  value = azurerm_storage_container.tf_state.id
}
output "tf_state_storage_account_id" {
  value = azurerm_storage_account.tf_state.id
}
output "tf_state_access_key" {
  value     = data.external.access_key.result
  sensitive = true
}
