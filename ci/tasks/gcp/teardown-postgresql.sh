#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

echo "    --> update_examples_git_ref"
update_examples_git_ref

echo "    --> init_gcloud"
init_gcloud

echo "    --> init_bootstrap_gcp"
init_bootstrap_gcp

echo "    --> write_users"
write_users

echo "    --> bin/prep-inception.sh"
bin/prep-inception.sh

echo "    --> prepare ssh login to bastion"
bastion_name="$(cd inception && tofu output bastion_name | jq -r)"
bastion_zone="$(cd inception && tofu output bastion_zone | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

echo "    --> bin/prep-postgresql.sh"
bin/prep-postgresql.sh

echo "    --> make destroy-postgresql on bastion with"
echo "        SERVICE_ACCOUNT (on local) = $SERVICE_ACCOUNT"
echo "        SERVICE_ACCOUNT (on bastion) = $(cat ./inception-sa-creds.json  | jq -r '.client_email')"
echo "        BASTION_USER = $BASTION_USER"
echo "        ADDITIONAL_SSH_OPTS = $ADDITIONAL_SSH_OPTS"
echo "        bastion_name = $bastion_name"
echo "        bastion_zone = $bastion_zone"
gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "cd repo-pg/examples/gcp; export TF_VAR_destroyable_postgres=true; export GOOGLE_APPLICATION_CREDENTIALS=\$(pwd)/inception-sa-creds.json; echo yes | make destroy-postgresql"
