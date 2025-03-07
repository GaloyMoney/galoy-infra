#!/bin/bash

set -eu

pushd bootstrap

tofu output | grep -v sensitive > ../inception/terraform.tfvars

tf_state_storage_account=$(tofu output tf_state_storage_account | jq -r)
tf_state_storage_blob_name=$(tofu output tf_state_storage_blob_name | jq -r)
tf_state_storage_container=$(tofu output tf_state_storage_container | jq -r)
tf_state_storage_account_id=$(tofu output tf_state_storage_account_id | jq -r)
tf_state_storage_blob_id=$(tofu output tf_state_storage_blob_id | jq -r)
tf_state_storage_container_id=$(tofu output tf_state_storage_container_id | jq -r)
resource_group_name=$(tofu output resource_group_name | jq -r)
access_key=$(tofu output -json access_key | jq -r ".access_key")

popd

export ARM_ACCESS_KEY=$access_key

pushd inception

cat <<EOF > terraform.tf
terraform {
  backend "azurerm" {
    resource_group_name = "${resource_group_name}"
    storage_account_name = "${tf_state_storage_account}"
    container_name       = "${tf_state_storage_container}"
    key                  = "inception.tfstate"
  }
}
EOF

tofu init
tofu state show module.inception.azurerm_storage_account.bootstrap || \
  tofu import module.inception.azurerm_storage_account.bootstrap ${tf_state_storage_account_id}
 tofu state show module.inception.azurerm_storage_container.bootstrap || \
   tofu import module.inception.azurerm_storage_container.bootstrap ${tf_state_storage_container_id}
 tofu state show module.inception.azurerm_storage_blob.tf_state || \
   tofu import module.inception.azurerm_storage_blob.tf_state ${tf_state_storage_blob_id}

