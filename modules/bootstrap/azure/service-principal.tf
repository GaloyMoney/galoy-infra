# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id = local.tenant_id
}
# Create an application
resource "azuread_application" "inception" {
  display_name = local.inception_app_name
}
provider "azurerm" {
  subscription_id = local.subscription_id
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
  end_date       = timeadd(timestamp(), "720h") # expire in 3 years
}

data "azurerm_subscription" "current" {
}

# Create Contributor role assignment for Service Principal
resource "azurerm_role_assignment" "bootstrap_spn_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.bootstrap.object_id
}
