#!/bin/bash

set -eu

pushd bootstrap

terraform output | grep -v sensitive > ../inception/terraform.tfvars

tf_state_storage_account=$(terraform output tf_state_storage_account | jq -r)
tf_state_storage_blob_name=$(terraform output tf_state_storage_blob_name | jq -r)
tf_state_storage_container=$(terraform output tf_state_storage_container | jq -r)
resource_group_name=$(terraform output resource_group_name | jq -r)
name_prefix=$(terraform output name_prefix | jq -r)
client_id=$(terraform output application_id | jq -r)
client_secret=$(terraform output client_secret | jq -r)
tenant_id=$(terraform output tenant_id | jq -r)
subscription_id=$(terraform output subscription_id | jq -r)

popd

echo "===================== $client_id ================="

export ARM_CLIENT_ID=$client_id
export ARM_CLIENT_SECRET=$client_secret
export ARM_TENANT_ID=$tenant_id
export ARM_SUBSCRIPTION_ID=$subscription_id

ACCOUNT_KEY=$(az storage account keys list --resource-group $resource_group_name --account-name $tf_state_storage_account --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY

pushd inception

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
