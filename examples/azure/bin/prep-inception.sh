#!/bin/bash

set -eu

pushd bootstrap

tofu output | grep -v sensitive > ../inception/terraform.tfvars

tf_state_storage_account=$(tofu output tf_state_storage_account | jq -r)
tf_state_storage_container=$(tofu output tf_state_storage_container | jq -r)
resource_group_name=$(tofu output resource_group_name | jq -r)
access_key=$(tofu output -json access_key | jq -r ".access_key")
inception_sp_id=$(tofu output -json inception_sp_id | jq -r)
name_prefix=$(tofu output -json name_prefix | jq -r)

popd

export ARM_ACCESS_KEY=$access_key

pushd inception

cat <<EOF > terraform.tfvars
inception_sp_id = "${inception_sp_id}"
name_prefix = "${name_prefix}"
EOF

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
