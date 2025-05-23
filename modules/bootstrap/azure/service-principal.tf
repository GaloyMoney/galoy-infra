data "azuread_application_published_app_ids" "well_known" {}
data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
}
# Create an application
resource "azuread_application" "inception" {
  display_name = local.inception_app_name

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = data.azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
      type = "Role"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
# Create a service principal
resource "azuread_service_principal" "inception" {
  client_id = azuread_application.inception.client_id
}

# Create app role assignment for Service Principal
resource "azuread_app_role_assignment" "inception" {
  app_role_id         = data.azuread_service_principal.msgraph.app_role_ids["User.Read.All"]
  principal_object_id = azuread_service_principal.inception.object_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

# Create Application password (client secret)
resource "azuread_application_password" "inception_app_password" {
  application_id    = azuread_application.inception.id
  end_date_relative = "25920h"
}

data "azurerm_subscription" "current" {}

# Create Contributor role assignment for Service Principal
resource "azurerm_role_assignment" "inception_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.inception.object_id
}

resource "azurerm_role_definition" "bootstrap" {
  name        = "Bootstrap for ${local.name_prefix}"
  scope       = data.azurerm_subscription.current.id
  description = "Role for bootstrapping inception tf files"

  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
    ]
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}

resource "azurerm_role_assignment" "inception_bootstrap" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = azurerm_role_definition.bootstrap.name
  principal_id         = azuread_service_principal.inception.object_id
}
