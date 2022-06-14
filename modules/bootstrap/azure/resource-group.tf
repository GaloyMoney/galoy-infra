# Create resource group
resource "azurerm_resource_group" "bootstrap" {
  name     = "${local.name_prefix}-bootstrap"
  location = local.resource_group_location
}
