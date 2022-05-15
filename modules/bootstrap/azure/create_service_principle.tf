# Configure Terraform
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id = "00000000-0000-0000-0000-000000000000"
}

# Retrieve domain information
data "azuread_domains" "example" {
  only_initial = true
}

# Create an application
resource "azuread_application" "example" {
  display_name = "ExampleApp"
}

# Create a service principal
resource "azuread_service_principal" "example" {
  application_id = azuread_application.example.application_id
}

# Create a user
resource "azuread_user" "example" {
  user_principal_name = "ExampleUser@${data.azuread_domains.example.domains.0.domain_name}"
  display_name        = "Example User"
  password            = "..."
}
