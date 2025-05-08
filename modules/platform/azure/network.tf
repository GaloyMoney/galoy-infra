data "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "cluster" {
  name                 = "${local.name_prefix}-cluster"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["${local.network_prefix}.0.0/17"]
}
