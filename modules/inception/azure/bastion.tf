resource "azurerm_bastion_host" "bastion" {
  name                = "${local.name_prefix}-bastion"
  location            = azurerm_resource_group.bootstrap.location
  resource_group_name = azurerm_resource_group.bootstrap.name

  ip_configuration {
    name                 = "${local.name_prefix}-bastion-ip-configuration"
    subnet_id            = azurerm_subnet.bastionSubnet.id
    public_ip_address_id = azurerm_public_ip.bastionIP.id
  }
}
