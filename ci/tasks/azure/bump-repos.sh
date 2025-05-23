#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh
pushd repo/examples/azure
update_examples_git_ref || true
make_commit "chore(examples): bump azure modules to '${MODULES_GIT_REF}' in examples"
popd

pushd galoy-staging

make bump-vendored-ref DEP=infra REF=${MODULES_GIT_LONG_REF}

cat > github.key <<EOF
${GITHUB_SSH_KEY}
EOF
GITHUB_SSH_KEY_BASE64=$(base64 -w 0 ./github.key) make vendir

make_commit "chore(deps): bump galoy-infra azure modules to '${MODULES_GIT_REF}'"
