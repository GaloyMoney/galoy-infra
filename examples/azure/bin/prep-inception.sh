#!/bin/bash

set -eu

pushd bootstrap

terraform output | grep -v sensitive > ../inception/terraform.tfvars

tf_state_storage_account=$(terraform output tf_state_storage_account | jq -r)
tf_state_storage_blob_name=$(terraform output tf_state_storage_blob_name | jq -r)
tf_state_storage_container=$(terraform output tf_state_storage_container | jq -r)
tf_state_storage_account_id=$(terraform output tf_state_storage_account_id | jq -r)
tf_state_storage_blob_id=$(terraform output tf_state_storage_blob_id | jq -r)
tf_state_storage_container_id=$(terraform output tf_state_storage_container_id | jq -r)
resource_group_name=$(terraform output resource_group_name | jq -r)
name_prefix=$(terraform output name_prefix | jq -r)
client_id=$(terraform output application_id | jq -r)
client_secret=$(terraform output client_secret | jq -r)
tenant_id=$(terraform output tenant_id | jq -r)
subscription_id=$(terraform output subscription_id | jq -r)
access_key=$(terraform output -json access_key | jq -r ".access_key")

popd



export ARM_CLIENT_ID=$client_id
export ARM_CLIENT_SECRET=$client_secret
export ARM_TENANT_ID=$tenant_id
export ARM_SUBSCRIPTION_ID=$subscription_id
export ARM_ACCESS_KEY=$access_key

<<<<<<< HEAD
pushd inception
=======
# ACCOUNT_KEY=$(az storage account keys list --resource-group $resource_group_name --account-name $tf_state_storage_account --query '[0].value' -o tsv)
# echo $ACCOUNT_KEY
export ARM_ACCESS_KEY=$access_key
>>>>>>> 85702a6 (runner upto inception is working)

pushd inception

cat <<EOF > terraform.tf
terraform {
  backend "azurerm" {
    subscription_id = "${subscription_id}"
    resource_group_name = "${resource_group_name}"
    storage_account_name = "${tf_state_storage_account}"
    container_name       = "${tf_state_storage_container}"
    key                  = "inception.tfstate"
  }
}
EOF

terraform init -reconfigure
terraform state show module.inception.azurerm_storage_account.bootstrap || \
  terraform import module.inception.azurerm_storage_account.bootstrap ${tf_state_storage_account_id}
 terraform state show module.inception.azurerm_storage_container.bootstrap || \
   terraform import module.inception.azurerm_storage_container.bootstrap ${tf_state_storage_container_id}
 terraform state show module.inception.azurerm_storage_blob.tf_state || \
   terraform import module.inception.azurerm_storage_blob.tf_state ${tf_state_storage_blob_id}

