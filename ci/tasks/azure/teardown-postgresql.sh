#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/azure

update_examples_git_ref

init_azure
init_kubeconfig
init_bootstrap_azure

write_users

bin/prep-inception.sh

bastion_name="$(cd inception && tofu output bastion_name | jq -r)"
bastion_zone="$(cd inception && tofu output bastion_zone | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/azure-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

bin/prep-postgresql.sh

az vm run-command invoke \
  --resource-group $(cd inception && tofu output resource_group | jq -r) \
  --name ${bastion_name} \
  --command-id RunShellScript \
  --scripts "cd repo-pg/examples/azure; export TF_VAR_destroyable_postgres=true; export AZURE_CREDENTIALS=\$(pwd)/azure-creds.json; echo yes | make destroy-postgresql"
