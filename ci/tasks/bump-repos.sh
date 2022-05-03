#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh
pushd repo/examples/gcp
update_examples_git_ref
make_commit "Bump modules to '${MODULES_GIT_REF}' in examples"
popd

pushd galoy-staging

make bump-vendored-ref DEP=infra REF=${MODULES_GIT_LONG_REF}

cat > github.key <<EOF
${GITHUB_SSH_KEY}
EOF
GITHUB_SSH_KEY_BASE64=$(base64 -w 0 ./github.key) make vendir

make_commit "Bump galoy-infra modules to '${MODULES_GIT_REF}'"
