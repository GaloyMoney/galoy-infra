#!/bin/bash

echo "    --> Starting bump-repos.sh"

set -eu

echo "    --> source pipeline-tasks/ci/tasks/helpers.sh and cd to repo/examples/gcp"
source pipeline-tasks/ci/tasks/helpers.sh
pushd repo/examples/gcp

echo "    --> update_examples_git_ref"
update_examples_git_ref

echo "    --> make_commit for examples"
make_commit "chore(examples): bump gcp modules to '${MODULES_GIT_REF}' in examples"
popd


echo "    --> cd to galoy-staging"
pushd galoy-staging

echo "    --> make bump-vendored-ref DEP=infra REF=${MODULES_GIT_LONG_REF}"
make bump-vendored-ref DEP=infra REF=${MODULES_GIT_LONG_REF}

cat > github.key <<EOF
${GITHUB_SSH_KEY}
EOF
GITHUB_SSH_KEY_BASE64=$(base64 -w 0 ./github.key) make vendir

echo "    --> make_commit "
make_commit "chore(deps): bump blink-infra gcp modules to '${MODULES_GIT_REF}'"

echo "    --> Done in bump-repos.sh"
