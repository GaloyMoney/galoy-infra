resource "azurerm_storage_account" "bootstrap" {
  name                     = "${local.name_prefix}StorageAcc"
  resource_group_name      = azurerm_resource_group.bootstrap.name
  location                 = local.tf_state_storage_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "bootstrap" {
  name                  = "${local.name_prefix}StorageCon"
  storage_account_name  = azurerm_storage_account.bootstrap.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "tf_state" {
  name                   = "${local.name_prefix}-tf-state"
  storage_account_name   = azurerm_storage_account.bootstrap.name
  storage_container_name = azurerm_storage_container.bootstrap.name
  type                   = "Block"
}