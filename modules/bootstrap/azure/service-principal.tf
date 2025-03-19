# Create an application
resource "azuread_application" "inception" {
  display_name = local.inception_app_name
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
# Create a service principal
resource "azuread_service_principal" "bootstrap" {
  client_id = azuread_application.inception.client_id
}

# Create Application password (client secret)
resource "azuread_application_password" "inception_app_password" {
  application_id = azuread_application.inception.id
}

data "azurerm_subscription" "current" {}

# Create Contributor role assignment for Service Principal
resource "azurerm_role_assignment" "bootstrap_spn_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.bootstrap.object_id
}
