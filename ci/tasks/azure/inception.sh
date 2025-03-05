#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/azure

update_examples_git_ref || true

init_kubeconfig
init_bootstrap_azure

echo yes | make inception
