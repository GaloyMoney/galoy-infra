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

bastion_name="$(cd inception && terraform output bastion_name | jq -r)"
bastion_zone="$(cd inception && terraform output bastion_zone | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

bin/prep-postgresql.sh

gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "cd repo-pg/examples/gcp; export TF_VAR_destroyable_postgres=true; export GOOGLE_APPLICATION_CREDENTIALS=\$(pwd)/gcloud-creds.json; echo yes | make destroy-postgresql"
