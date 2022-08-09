resource "azurerm_virtual_network" "vnet" {
  name                = "${local.name_prefix}-vnet"
  address_space       = ["${local.network_prefix}.0.0/16"]
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name
}

resource "azurerm_subnet" "bastionSubnet" {
  name                 = "${local.name_prefix}-bastionSubnet"
  resource_group_name  = azurerm_resource_group.bootstrap.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${local.network_prefix}.0.0/24"]
}

resource "azurerm_public_ip" "bastionIP" {
  name                = "${local.name_prefix}-bastionIP"
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
