#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

update_examples_git_ref

init_gcloud
init_kubeconfig
init_bootstrap_gcp

write_users

echo yes | TF_VAR_tf_state_bucket_force_destroy=true \
  make bootstrap

cleanup_inception_key
