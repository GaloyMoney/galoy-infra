#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh
pushd repo/examples/gcp
update_examples_git_ref
make_commit "Bump modules to '${MODULES_GIT_REF}' in examples"
popd

pushd galoy-staging/gcp/staging

echo "Bumping refs for galoy-staging"
sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" bootstrap/main.tf
sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" inception/main.tf
sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" platform/main.tf
sed -i'' "s/ref=.*\"/ref=${MODULES_GIT_REF}\"/" services/main.tf

make_commit "Bump modules to '${MODULES_GIT_REF}' in gcp/staging"
