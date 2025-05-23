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

bastion_name="$(cd inception && tofu output bastion_name | jq -r)"
bastion_zone="$(cd inception && tofu output bastion_zone | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

gcloud compute os-login ssh-keys add --key-file=${CI_ROOT}/login.ssh.pub

cp ${CI_ROOT}/gcloud-creds.json ./
bin/prep-postgresql.sh

set +e
for i in {1..60}; do
  echo "Attempt ${i} to find make and tofu on bastion"
  gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "which make && which tofu" && break
  sleep 2
done
set -e

gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "cd repo-pg/examples/gcp; export TF_VAR_destroyable_postgres=true; export GOOGLE_APPLICATION_CREDENTIALS=\$(pwd)/gcloud-creds.json; echo yes | make postgresql"
