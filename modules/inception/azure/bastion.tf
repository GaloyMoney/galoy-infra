locals {
  cepler_version   = "0.7.15"
  kubectl_version  = "1.30.4"
  k9s_version      = "0.32.5"
  opentofu_version = "1.9.0"
}

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_machine" "bastion" {
  name                  = "${local.name_prefix}-bastion"
  location              = data.azurerm_resource_group.resource_group.location
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.bastion_network_interface.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${local.name_prefix}-bastion-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${local.name_prefix}-bastion"
    admin_username = "galoy"
    custom_data = base64encode(templatefile("${path.module}/bastion-startup.tmpl", {
      cepler_version : local.cepler_version
      kubectl_version : local.kubectl_version
      k9s_version : local.k9s_version
      opentofu_version : local.opentofu_version
    }))
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/galoy/.ssh/authorized_keys"
      key_data = tls_private_key.bastion_key.public_key_openssh
    }
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "aadlogin" {
  name                 = "AADSSHLoginForLinux"
  virtual_machine_id   = azurerm_virtual_machine.bastion.id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADSSHLoginForLinux"
  type_handler_version = "1.0"
}
