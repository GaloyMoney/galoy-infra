data "azuread_user" "bastion_users" {
  for_each      = toset(local.bastion_users)
  mail_nickname = each.value
}

resource "azurerm_role_assignment" "bastion_access" {
  for_each             = data.azuread_user.bastion_users
  scope                = azurerm_virtual_machine.bastion.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = each.value.object_id
}
