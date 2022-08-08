# Configure the Azure Active Directory Provider
provider "azuread" {}

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
  end_date_relative     = "3600h" 
}

<<<<<<< HEAD
data "azurerm_subscription" "current" {
}

=======
>>>>>>> b8e51c0 (removed unused comment block)
data "azurerm_subscription" "current" {
}

# Create Contributor role assignment for Service Principal
resource "azurerm_role_assignment" "bootstrap_spn_contributor" {
<<<<<<< HEAD
<<<<<<< HEAD
  scope                = data.azurerm_subscription.current.id
=======
  scope                = data.azurerm_subscription.current.display_name
>>>>>>> 1ca5d9c (fix spn creation for app reg)
=======
  scope                = data.azurerm_subscription.current.id
>>>>>>> 48df8e6 (fix spn scope arguments)
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.bootstrap.id
}
