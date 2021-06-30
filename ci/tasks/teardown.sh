#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

init_kubeconfig

cat <<EOF >> bootstrap/added-in-ci.tf
terraform {
  backend "kubernetes" {
    secret_suffix = "testflight"
    namespace = "concourse-tf"
  }
}
EOF

update_examples_git_ref

make init
make teardown

make_commit "Bump modules to '${GIT_REF}' in examples"
