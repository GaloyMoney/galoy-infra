output "bastion_password" {
  value     = random_password.password.result
  sensitive = true
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_ni_public_ip.ip_address
}

ouptut "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
