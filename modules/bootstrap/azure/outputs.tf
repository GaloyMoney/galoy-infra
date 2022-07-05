output "tf_state_storage_blob_name" {
  value = azurerm_storage_blob.tf_state.name
}
output "tf_state_storage_location" {
  value = azurerm_storage_account.bootstrap.location
}
output "tf_state_storage_account" {
  value = azurerm_storage_account.bootstrap.name
}
<<<<<<< HEAD
output "resource_group" {
  value = azurerm_resource_group.bootstrap.name
=======
output "client_id" {
  value = azuread_application.inception.application_id
}
output "client_secret" {
  value     = azuread_application_password.inception_app_password.value
  sensitive = true
>>>>>>> c102f61 (test spn creation for running inception)
}
