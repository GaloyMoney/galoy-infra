#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/azure

update_examples_git_ref || true

init_kubeconfig
init_bootstrap_azure

# Get the name prefix from bootstrap output
name_prefix=$(cd bootstrap && tofu output name_prefix | jq -r)

# Configure SSH for bastion host
az ssh config -g ${name_prefix} -n ${name_prefix}-bastion -f ./sshconfig

# Execute teardown on bastion host
ssh -F ./sshconfig ${name_prefix}-${name_prefix}-bastion -- 'cd repo-pg/examples/azure; echo yes | make destroy-postgresql'
