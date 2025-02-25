#!/bin/bash

set -eu

pushd bootstrap

tf_state_storage_account=$(tofu output tf_state_storage_account | jq -r)
subscription_id=$(tofu output subscription_id | jq -r)
resource_group_name=$(tofu output resource_group_name | jq -r)
tf_state_storage_container=$(tofu output tf_state_storage_container | jq -r)
name_prefix=$(tofu output name_prefix | jq -r)
popd

pushd inception

vnet_name=$(tofu output vnet_name | jq -r)

popd

pushd platform

cat <<EOF > terraform.tf
terraform {
  backend "azurerm" {
    subscription_id = "${subscription_id}"
    resource_group_name = "${resource_group_name}"
    storage_account_name = "${tf_state_storage_account}"
    container_name       = "${tf_state_storage_container}"
    key                  = "platform.tfstate"
  }
}
EOF

cat <<EOF > terraform.tfvars
name_prefix = "${name_prefix}"
subscription_id = "${subscription_id}"
resource_group_name = "${resource_group_name}"
vnet_name = "${vnet_name}"
EOF

tofu init
popd

