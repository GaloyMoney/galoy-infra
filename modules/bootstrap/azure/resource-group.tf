# Create resource group
resource "azurerm_resource_group" "resource_group" {
  name     = local.name_prefix
  location = local.resource_group_location
}
