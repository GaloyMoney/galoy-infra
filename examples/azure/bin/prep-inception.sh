#!/bin/bash

set -eu

pushd bootstrap

terraform output > ../inception/terraform.tfvars

tf_state_storage_account=$(terraform output tf_state_storage_account | jq -r)
tf_state_storage_blob_name=$(terraform output tf_state_storage_blob_name | jq -r)
tf_state_storage_container=$(terraform output tf_state_storage_container | jq -r)
resource_group_name=$(terraform output resource_group | jq -r)
name_prefix=$(terraform output name_prefix | jq -r)

popd

export ARM_CLIENT_ID = #@ data.values.testflight_azure_client_id
export ARM_CLIENT_SECRET = #@ data.values.testflight_azure_client_secret
#export ARM_TENANT_ID = #@ data.values.testflight_azure_tenant_id
#export ARM_SUBSCRIPTION_ID = 
pushd inception

ACCOUNT_KEY=$(az storage account keys list --resource-group $resource_group_name --account-name $tf_state_storage_account --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY

cat <<EOF > terraform.tf
terraform {
  backend "azurerm" {
    resource_group_name = "${resource_group_name}"
    storage_account_name = "${tf_state_storage_account}"
    container_name       = "${tf_state_storage_container}"
    key                  = "terraform.tfstate"
  }
}
EOF

terraform init
terraform state show module.inception.azurerm_storage_account.bootstrap || \
  terraform import module.inception.azurerm_storage_account.bootstrap ${tf_state_storage_account}
terraform state show module.inception.azurerm_storage_container.bootstrap || \
  terraform import module.inception.azurerm_storage_container.bootstrap ${tf_state_storage_container}
terraform state show module.inception.azurerm_storage_blob.tf_state || \
  terraform import module.inception.azurerm_storage_blob.tf_state ${tf_state_storage_blob_name}

terraform apply 

