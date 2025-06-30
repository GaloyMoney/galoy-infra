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

SERVICE_ACCOUNT=$(cat inception-sa-creds.json | jq -r '.client_email')
echo "    --> make platform with user $SERVICE_ACCOUNT"
echo yes | GOOGLE_CREDENTIALS=$(cat inception-sa-creds.json) make platform

echo "    --> cleanup_inception_key"
cleanup_inception_key
