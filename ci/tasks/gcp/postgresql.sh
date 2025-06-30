#!/bin/bash

set -eu

echo "    --> source pipeline-tasks/ci/tasks/helpers.sh"
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

bastion_name="$(cd inception && tofu output bastion_name | jq -r)"
bastion_zone="$(cd inception && tofu output bastion_zone | jq -r)"
BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export BASTION_USER
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"
echo "    --> prepare ssh login to bastion"
echo "        SERVICE_ACCOUNT: $SERVICE_ACCOUNT"
echo "        BASTION_USER: $BASTION_USER"
echo "        ADDITIONAL_SSH_OPTS: $ADDITIONAL_SSH_OPTS"
gcloud compute os-login ssh-keys add --key-file=${CI_ROOT}/login.ssh.pub

cp ${CI_ROOT}/gcloud-creds.json ./

echo "    --> bin/prep-postgresql.sh"
bin/prep-postgresql.sh

echo "    --> wait for bastion to be ready"
set +e
for i in {1..60}; do
  echo "Attempt ${i} to find make and tofu on bastion"
  gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "which make && which tofu" && break
  sleep 2
done
set -e

echo "    --> checking SERVICE_ACCOUNT on bastion"
gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "cat repo-pg/examples/gcp/inception-sa-creds.json | jq -r '.client_email'"

echo "    --> make postgresql on bastion with"
echo "        SERVICE_ACCOUNT: $SERVICE_ACCOUNT"
echo "        BASTION_USER: $BASTION_USER"
echo "        ADDITIONAL_SSH_OPTS: $ADDITIONAL_SSH_OPTS"
gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "cd repo-pg/examples/gcp; export TF_VAR_destroyable_postgres=true; export GOOGLE_APPLICATION_CREDENTIALS=\$(pwd)/inception-sa-creds.json; echo yes | make postgresql"

echo "    --> cleanup_inception_key"
cleanup_inception_key
