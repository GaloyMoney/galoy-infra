#!/bin/bash

set -eu

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_ROOT_DIR="${REPO_ROOT##*/}"

pushd bootstrap

tf_state_bucket_name=$(terraform output tf_state_bucket_name | jq -r)
name_prefix=$(terraform output name_prefix | jq -r)

popd

pushd inception

cluster_sa=$(terraform output cluster_sa | jq -r)
bastion_name="$(terraform output bastion_name | jq -r)"
bastion_zone="$(terraform output bastion_zone | jq -r)"

popd

pushd platform

cluster_endpoint=$(terraform output cluster_endpoint | jq -r)
cluster_ca_cert="$(terraform output -json cluster_ca_cert | jq -r)"

popd

pushd services

cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/services"
  }
}
EOF

cat <<EOF >> terraform.tfvars
name_prefix = "${name_prefix}"
cluster_endpoint = "${cluster_endpoint}"
cluster_ca_cert = <<-EOT
${cluster_ca_cert}
EOT
EOF

popd

gcloud compute start-iap-tunnel ${bastion_name} --zone=${bastion_zone} 22 --local-host-port=localhost:2222 &
sleep 5
trap 'jobs -p | xargs kill' EXIT

ADDITIONAL_SSH_OPTS=${ADDITIONAL_SSH_OPTS:-""}
echo "Syncing ${REPO_ROOT##*/} to bastion"
rsync --exclude '**/.terraform/**' --exclude '**.terrafor*' -avr -e "ssh -l ${BASTION_USER} ${ADDITIONAL_SSH_OPTS} -p 2222 " \
  ${REPO_ROOT}/ localhost:${REPO_ROOT_DIR}
