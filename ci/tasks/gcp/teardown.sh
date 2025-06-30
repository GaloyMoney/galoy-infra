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
echo "    --> bin/prep-platform.sh"
bin/prep-platform.sh

bastion_name="$(cd inception && tofu output bastion_name | jq -r)"
bastion_zone="$(cd inception && tofu output bastion_zone | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

echo "    --> bin/prep-smoketest.sh"
bin/prep-smoketest.sh

echo "    --> make destroy-smoketest on bastion ${bastion_name}"
gcloud compute ssh --ssh-key-file=${CI_ROOT}/login.ssh ${bastion_name} --zone=${bastion_zone} -- "cd repo/examples/gcp; export GOOGLE_APPLICATION_CREDENTIALS=\$(pwd)/inception-sa-creds.json; echo yes | make destroy-smoketest"

echo "    --> make destroy-platform"
echo yes | make destroy-platform

echo "    --> delete servicenetworking-googleapis-com peering"
set +e
gcloud compute networks peerings delete servicenetworking-googleapis-com --network ${TF_VAR_name_prefix}-vpc --quiet
set -e

# Sometimes a resource deletion fails if a dependent resource is still being deleted
success=0
for i in {1..5}; do
  echo "    --> Attempt $i to destroy inception"
  echo yes | GOOGLE_CREDENTIALS=$(cat inception-sa-creds.json) make destroy-inception && success=1 && break
  sleep 10
done

if [ $success -eq 1 ]; then
  echo "    --> destroy-bootstrap"
  echo yes | TF_VAR_tf_state_bucket_force_destroy=true make destroy-bootstrap
  echo "    --> Deleting local state file"
  # Delete the local state file after successful bootstrap destruction
  cd ../../../bootstrap-tf-state/
  git rm -f bootstrap.tfstate
  echo "    --> Committing changes"
  config_git
  git add -A
  git commit -am "remove bootstrap tfstate"
else
  exit 1
fi
