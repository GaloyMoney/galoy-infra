#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

update_examples_git_ref

init_gcloud

init_kubeconfig
init_bootstrap

write_users

bin/prep-inception.sh

bastion_ip="$(cd inception && terraform output bastion_ip | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

set +e
for i in {1..60}; do
  echo "Attempt ${i} to ssh to bastion"
  ssh ${ADDITIONAL_SSH_OPTS} ${BASTION_USER}@${bastion_ip} "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" && apt-get update && apt-get install -y make terraform" && break
  sleep 2
done
set -e

bin/prep-bastion.sh

ssh ${ADDITIONAL_SSH_OPTS} ${BASTION_USER}@${bastion_ip} "cd repo/examples/gcp; echo yes | make platform"
