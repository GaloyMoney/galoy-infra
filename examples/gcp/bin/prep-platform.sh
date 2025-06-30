#!/bin/bash

echo "    --> prep-platform.sh"

set -eu

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_ROOT_DIR="${REPO_ROOT##*/}"

pushd bootstrap

echo "    --> bootstrap outputs"
tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
name_prefix=$(tofu output name_prefix | jq -r)
gcp_project=$(tofu output gcp_project | jq -r)
echo "    --> results:"
echo "        tf_state_bucket_name: ${tf_state_bucket_name}"
echo "        name_prefix: ${name_prefix}"
echo "        gcp_project: ${gcp_project}"

popd

pushd inception

cluster_sa=$(tofu output cluster_sa | jq -r)

popd

pushd platform

echo "    --> create terraform.tf backend config"
cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/platform"
  }
}
EOF

echo "    --> create terraform.tfvars"
echo "        gcp_project = \"${gcp_project}\""
echo "        name_prefix = \"${name_prefix}\""
echo "        node_service_account = \"${cluster_sa}\""
echo "        destroyable_cluster = true"

cat <<EOF > terraform.tfvars
gcp_project = "${gcp_project}"
name_prefix = "${name_prefix}"
node_service_account = "${cluster_sa}"
destroyable_cluster = true
EOF

echo "    --> tofu init"
tofu init
popd

echo "    --> end prep-platform.sh"
