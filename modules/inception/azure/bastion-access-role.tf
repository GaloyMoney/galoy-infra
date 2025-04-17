data "azuread_user" "bastion_users" {
  for_each      = toset(local.bastion_users)
  mail_nickname = each.value
}

resource "azurerm_role_assignment" "bastion_access" {
  for_each             = toset(concat([for user in data.azuread_user.bastion_users : user.object_id], [local.inception_sp_id]))
  scope                = data.azurerm_resource_group.resource_group.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = each.value
}
