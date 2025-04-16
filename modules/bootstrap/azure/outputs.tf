output "tf_state_storage_container" {
  value = azurerm_storage_container.tf_state.name
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

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}
output "name_prefix" {
  value = local.name_prefix
}
output "tf_state_access_key" {
  value     = data.external.access_key.result
  sensitive = true
}
output "inception_sp_id" {
  value = azuread_service_principal.inception.object_id
}
