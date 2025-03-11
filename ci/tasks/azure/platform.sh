#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/azure

update_examples_git_ref

init_kubeconfig
init_bootstrap_azure

bin/prep-inception.sh

bin/prep-platform.sh
echo yes | make platform
