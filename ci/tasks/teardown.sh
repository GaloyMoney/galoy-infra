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

echo yes | GOOGLE_CREDENTIALS=$(cat inception-sa-creds.json) make destroy-inception
echo yes | TF_VAR_tf_state_bucket_force_destroy=true make destroy-bootstrap

make_commit "Bump modules to '${MODULES_GIT_REF}' in examples"
