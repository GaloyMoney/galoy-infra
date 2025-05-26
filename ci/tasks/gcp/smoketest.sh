#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

echo "    --> update_examples_git_ref"
update_examples_git_ref

echo "    --> init_gcloud"
init_gcloud

echo "    --> init_kubeconfig"
init_kubeconfig
echo "    --> init_bootstrap_gcp"
init_bootstrap_gcp

echo "    --> write_users"
write_users

echo "    --> bin/prep-inception.sh"
bin/prep-inception.sh
echo "    --> cleanup_inception_key"
cleanup_inception_key

echo "    --> bin/prep-platform.sh"
bin/prep-platform.sh

echo "    --> prepare ssh login to bastion"
bastion_name="$(cd inception && tofu output bastion_name | jq -r)"
bastion_zone="$(cd inception && tofu output bastion_zone | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"
gcloud compute os-login ssh-keys add --key-file=${CI_ROOT}/login.ssh.pub

cp ${CI_ROOT}/gcloud-creds.json ./

echo "    --> bin/prep-smoketest.sh"
bin/prep-smoketest.sh

echo "    --> wait for bastion to be ready"
set +e
for i in {1..60}; do
  echo "Attempt ${i} to find make on bastion"
  gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "which make" && break
  sleep 2
done
set -e

SERVICE_ACCOUNT=$(cat gcloud-creds.json | jq -r '.client_email')
echo "    --> make smoketest on bastion with user $SERVICE_ACCOUNT"
gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "cd repo/examples/gcp; export GOOGLE_APPLICATION_CREDENTIALS=\$(pwd)/gcloud-creds.json; echo yes | make smoketest"

echo "    --> end smoketest.sh"
