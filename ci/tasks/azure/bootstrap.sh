#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/azure

update_examples_git_ref

init_kubeconfig
init_bootstrap

echo yes | make bootstrap 
