#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/azure

update_examples_git_ref || true

init_kubeconfig
init_bootstrap_azure

az login --service-principal -u ${AZURE_CLIENT_ID} -p ${AZURE_CLIENT_SECRET} -t ${AZURE_TENANT_ID}
bin/prep-postgresql.sh

name_prefix=$(cd bootstrap && tofu output name_prefix | jq -r)
az ssh config -g ${name_prefix} -n ${name_prefix}-bastion -f ./sshconfig

set +e
for i in {1..60}; do
  echo "Attempt ${i} to find make and tofu on bastion"
  ssh -F ./sshconfig ${name_prefix}-${name_prefix}-bastion -- 'which make && which tofu' && break
  sleep 2
done
set -e

ssh -F ./sshconfig ${name_prefix}-${name_prefix}-bastion -- 'cd repo-pg/examples/azure; echo yes | make postgresql'
