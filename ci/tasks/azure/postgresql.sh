#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/azure

update_examples_git_ref || true

init_kubeconfig
init_bootstrap_azure

pushd bootstrap

export ARM_CLIENT_ID=$(tofu output client_id | jq -r)
export ARM_CLIENT_SECRET=$(tofu output client_secret | jq -r)

popd

az login --service-principal -u ${ARM_CLIENT_ID} -p ${ARM_CLIENT_SECRET} -t ${ARM_TENANT_ID}
bin/prep-postgresql.sh

name_prefix=$(cd bootstrap && tofu output name_prefix | jq -r)

set +e
for i in {1..60}; do
  echo "Attempt ${i} to find make and tofu on bastion"
  ssh -F ./sshconfig ${name_prefix}-${name_prefix}-bastion -- 'which make && which tofu' && break
  sleep 2
done
set -e

ssh -F ./sshconfig ${name_prefix}-${name_prefix}-bastion -- 'cd repo/examples/azure; \
  export ARM_CLIENT_ID=${ARM_CLIENT_ID}; \
  export ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET}; \
  export ARM_TENANT_ID=${ARM_TENANT_ID}; \
  export ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID}; \
  echo yes | make postgresql'
