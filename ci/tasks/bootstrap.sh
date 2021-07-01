#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

update_examples_git_ref

init_gcloud
init_kubeconfig
init_bootstrap

echo yes | make bootstrap

cleanup_inception_key
