output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_ni_public_ip.ip_address
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
