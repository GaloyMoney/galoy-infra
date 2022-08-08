#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

update_examples_git_ref

init_gcloud

init_kubeconfig
init_bootstrap_gcp

write_users

bin/prep-inception.sh
cleanup_inception_key

bin/prep-platform.sh
echo yes | make platform
