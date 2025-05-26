#!/bin/bash

set -eu

echo "    --> source pipeline-tasks/ci/tasks/helpers.sh"
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

SERVICE_ACCOUNT=$(echo $GOOGLE_CREDENTIALS | jq -r '.client_email')
echo "    --> make bootstrap with user $SERVICE_ACCOUNT"
echo yes | TF_VAR_tf_state_bucket_force_destroy=true \
  make bootstrap

echo "    --> cleanup_inception_key"
cleanup_inception_key
