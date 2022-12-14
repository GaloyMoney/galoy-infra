#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

update_examples_git_ref

init_gcloud

init_kubeconfig
init_bootstrap_gcp

write_users

bin/prep-inception.sh
cleanup_inception_key

bin/prep-platform.sh

bastion_name="$(cd inception && terraform output bastion_name | jq -r)"
bastion_zone="$(cd inception && terraform output bastion_zone | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

gcloud compute os-login ssh-keys add --key-file=${CI_ROOT}/login.ssh.pub

cp ${CI_ROOT}/gcloud-creds.json ./
bin/prep-services.sh

set +e
for i in {1..60}; do
  echo "Attempt ${i} to find make on bastion"
  gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "which make" && break
  sleep 2
done
set -e

gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "cd repo/examples/gcp; export GOOGLE_APPLICATION_CREDENTIALS=\$(pwd)/gcloud-creds.json; export TF_VAR_enable_tracing=false; echo yes | make initial-services && echo yes | make services"
