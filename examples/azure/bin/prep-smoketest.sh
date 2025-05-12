#!/bin/bash

set -eu

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_ROOT_DIR="${REPO_ROOT##*/}"

pushd bootstrap

tf_state_storage_account=$(tofu output tf_state_storage_account | jq -r)
resource_group_name=$(tofu output resource_group_name | jq -r)
tf_state_storage_container=$(tofu output tf_state_storage_container | jq -r)
name_prefix=$(tofu output name_prefix | jq -r)
popd

pushd platform

cluster_endpoint=$(tofu output cluster_endpoint | jq -r)
cluster_ca_cert="$(tofu output -json cluster_ca_cert | jq -r)"

popd

pushd smoketest

cat <<EOF > terraform.tf
terraform {
  backend "azurerm" {
    resource_group_name = "${resource_group_name}"
    storage_account_name = "${tf_state_storage_account}"
    container_name       = "${tf_state_storage_container}"
    key                  = "${name_prefix}/smoketest.tfstate"
  }
}
EOF

cat <<EOF > terraform.tfvars
name_prefix = "${name_prefix}"
cluster_endpoint = "${cluster_endpoint}"
cluster_ca_cert = <<-EOT
${cluster_ca_cert}
EOT
EOF

popd

# Create ssh config file
rm ./sshconfig || true
rm -r ./az_ssh_config || true
az ssh config -g ${resource_group_name} -n ${name_prefix}-bastion -f ./sshconfig

ADDITIONAL_SSH_OPTS=${ADDITIONAL_SSH_OPTS:-""}
echo "Syncing ${REPO_ROOT##*/} to bastion"
rsync --exclude '**/.terraform/**' --exclude '**.terrafor*' -avr -e "ssh -F ./sshconfig -o StrictHostKeyChecking=no ${ADDITIONAL_SSH_OPTS}" \
  ${REPO_ROOT}/ ${name_prefix}-${name_prefix}-bastion:${REPO_ROOT_DIR}
