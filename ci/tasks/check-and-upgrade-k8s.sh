#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh
pushd pipeline-tasks/ci/k8s-upgrade

tofu init && tofu apply -auto-approve
LATEST_VERSION="$(tofu output -json | jq -r .latest_version.value)"

if [[ $LATEST_VERSION == "" ]]; then
  echo "Failed to get latest version"
  exit 1
fi

popd

pushd repo

CURRENT_VERSION=$(hcledit -f modules/platform/gcp/variables.tf attribute get variable.kube_version.default | tr -d '"')

if [[ "$(echo -e "$CURRENT_VERSION\n$LATEST_VERSION" | sort -V | head -n1)" != "$LATEST_VERSION" ]]; then
  echo "K8s upgrade from ${CURRENT_VERSION} to ${LATEST_VERSION} is available"
  hcledit -u -f modules/platform/gcp/variables.tf attribute set variable.kube_version.default \"$LATEST_VERSION\"
else
  echo "No upgrade available"
  exit 0
fi

make_commit "chore: bump kubernetes to '${LATEST_VERSION}'"
