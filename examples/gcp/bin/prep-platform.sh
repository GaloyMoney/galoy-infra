#!/bin/bash

set -eu

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_ROOT_DIR="${REPO_ROOT##*/}"

pushd bootstrap

tf_state_bucket_name=$(terraform output tf_state_bucket_name | jq -r)
name_prefix=$(terraform output name_prefix | jq -r)
gcp_project=$(terraform output gcp_project | jq -r)

popd

pushd inception

cluster_sa=$(terraform output cluster_sa | jq -r)
bastion_ip="$(terraform output bastion_ip | jq -r)"

popd

pushd platform

cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/platform"
  }
}
EOF

cat <<EOF >> terraform.tfvars
gcp_project = "${gcp_project}"
name_prefix = "${name_prefix}"
node_service_account = "${cluster_sa}"
EOF

popd
