#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd pipeline-tasks/ci/k8s-upgrade

terraform init && terraform apply -auto-approve
LATEST_VERSION="$(terraform output -json | jq .latest_version.value)"

popd

pushd repo

CURRENT_VERSION=$(hcledit -f modules/platform/gcp/variables.tf attribute get variable.kube_version.default)

if [ "$LATEST_VERSION" != "$CURRENT_VERSION" ]; then
  echo "K8s upgrade from ${CURRENT_VERSION} to ${LATEST_VERSION} is available"
  hcledit -u -f modules/platform/gcp/variables.tf attribute set variable.kube_version.default $LATEST_VERSION
else
  echo "No upgrade available"
fi

make_commit "Bump k8s to '${LATEST_VERSION}'"
