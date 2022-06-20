#!/bin/bash
apk add az

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/azure

# update_examples_git_ref

# init_azure
# init_kubeconfig
# init_bootstrap

# write_users

echo yes |  make bootstrap

# cleanup_inception_key
