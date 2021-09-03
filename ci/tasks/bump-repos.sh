#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh
pushd repo/examples/gcp
update_examples_git_ref
make_commit "Bump modules to '${MODULES_GIT_REF}' in examples"
popd

pushd galoy-staging/modules

echo "Bumping refs for galoy-staging"
sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" gcp/bootstrap/main.tf
sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" gcp/inception/main.tf
sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" gcp/platform/main.tf
sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" services/base/main.tf

make_commit "Bump galoy-infra modules to '${MODULES_GIT_REF}'"
