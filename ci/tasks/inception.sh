#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

update_examples_git_ref

init_gcloud
init_kubeconfig
init_bootstrap

write_users

bin/prep-inception.sh

echo yes | GOOGLE_CREDENTIALS=$(cat inception-sa-creds.json) make inception

echo "BASTION IP: $(bastion_ip)"

cleanup_inception_key
