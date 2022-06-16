output "tf_state_storage_blob_name" {
  value = azurerm_storage_blob.tf_state.name
}
output "tf_state_storage_location" {
  value = azurerm_storage_account.bootstrap.location
}
output "tf_state_storage_account" {
  value = azurerm_storage_account.bootstrap.name
}
