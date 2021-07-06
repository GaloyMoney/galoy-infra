!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh
pushd repo/examples/gcp
update_examples_git_ref
make_commit "Bump modules to '${MODULES_GIT_REF}' in examples"
popd

pushd galoy-deployments/gcp/staging
update_examples_git_ref
make_commit "Bump modules to '${MODULES_GIT_REF}' in deployments-staging"
