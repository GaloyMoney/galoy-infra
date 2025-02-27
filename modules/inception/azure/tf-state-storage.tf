resource "azurerm_storage_account" "bootstrap" {
  name                     = "${replace(lower(local.name_prefix), "/[^a-z0-9]/", "")}sa"
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  location                 = local.tf_state_storage_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "bootstrap" {
  name                  = "${local.name_prefix}-sc"
  storage_account_id    = azurerm_storage_account.bootstrap.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "tf_state" {
  name                   = "${local.name_prefix}-tf-state"
  storage_account_name   = azurerm_storage_account.bootstrap.name
  storage_container_name = azurerm_storage_container.bootstrap.name
  type                   = "Block"
}
