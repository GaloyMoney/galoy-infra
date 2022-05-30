# Configure Terraform

# Configure the Azure Active Directory Provider
#provider "azuread" {
#  tenant_id = local.tenant_id
#}

locals {
  inception_sa_name = "${local.name_prefix}-inception-tf"
}

# Create an application
resource "azuread_application" "inception" {
  tenant_id = local.tenant_id
  display_name = local.inception_sa_name
}

# Create a service principal
resource "azuread_service_principal" "bootstrap" {
  tenant_id = local.tenant_id
  application_id = azuread_application.inception.application_id
}


