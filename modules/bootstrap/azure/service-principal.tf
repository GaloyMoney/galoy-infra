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
