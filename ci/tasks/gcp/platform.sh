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

echo "    --> bin/prep-inception.sh"
bin/prep-inception.sh
echo "    --> cleanup_inception_key"
cleanup_inception_key

echo "    --> bin/prep-platform.sh"
bin/prep-platform.sh

echo "    --> make platform"
echo yes | make platform
