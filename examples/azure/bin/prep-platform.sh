#!/bin/bash

set -eu

pushd bootstrap

tf_state_storage_account=$(terraform output tf_state_storage_account | jq -r)
subscription_id=$(terraform output subscription_id | jq -r)
resource_group_name=$(terraform output resource_group_name | jq -r)
tf_state_storage_container=$(terraform output tf_state_storage_container | jq -r)
name_prefix=$(terraform output name_prefix | jq -r)
popd

pushd inception

vnet_name=$(terraform output vnet_name | jq -r)

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
resource_group_name = "${resource_group_name}"
vnet_name = "${vnet_name}"
EOF

terraform init
popd

