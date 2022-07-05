# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id = local.tenant_id
}

# Create an application
resource "azuread_application" "inception" {
  display_name = local.inception_app_name
}

provider "azurerm" {
  features {}
}

# Create a service principal
resource "azuread_service_principal" "bootstrap" {
  application_id = azuread_application.inception.application_id
}

# Create Application password (client secret)
resource "azuread_application_password" "inception_app_password" {
  application_object_id = azuread_application.inception.object_id
  end_date_relative     = "2h" # expire in 3 years
}

# # Create app role assignment for Service Principal
# resource "azuread_app_role_assignment" "bootstrap_spn_role" {
#   app_role_id         = azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
#   principal_object_id = azuread_service_principal.bootstrap.object_id
#   resource_object_id  = azuread_service_principal.msgraph.object_id
# }

data "azurerm_subscription" "current" {
}

# Create Contributor role assignment for Service Principal
resource "azurerm_role_assignment" "bootstrap_spn_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.bootstrap.id
}
