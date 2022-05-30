# Create resource group
resource "azurerm_resource_group" "bootstrap" {
  name     = "bootstrap"
  location = local.resource_group_location
}