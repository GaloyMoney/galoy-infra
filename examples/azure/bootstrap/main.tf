variable "name_prefix" {}
variable "tenant_id" {}

module "bootstrap" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/azure?ref=main"
  source = "../../../modules/bootstrap/azure"

  name_prefix = var.name_prefix
  tenant_id   = var.tenant_id
}

output "tf_state_storage_blob_name" {
  value = azurerm_storage_blob.tf_state.name
}
output "tf_state_storage_location" {
  value = azurerm_storage_account.bootstrap.location
}
output "tf_state_storage_account" {
  value = azurerm_storage_account.bootstrap.name
}

