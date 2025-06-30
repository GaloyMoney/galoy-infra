#!/bin/bash

set -eu

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_ROOT_DIR="${REPO_ROOT##*/}"

pushd bootstrap

tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
name_prefix=$(tofu output name_prefix | jq -r)

popd

pushd inception

cluster_sa=$(tofu output cluster_sa | jq -r)
bastion_name="$(tofu output bastion_name | jq -r)"
bastion_zone="$(tofu output bastion_zone | jq -r)"

popd

pushd platform

cluster_endpoint=$(tofu output cluster_endpoint | jq -r)
cluster_ca_cert="$(tofu output -json cluster_ca_cert | jq -r)"

popd

pushd smoketest

cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/smoketest"
  }
}
EOF

cat <<EOF > terraform.tfvars
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

set +e
ADDITIONAL_SSH_OPTS=${ADDITIONAL_SSH_OPTS:-""}
echo "    --> Syncing ${REPO_ROOT##*/} to bastion"
rsync --exclude '**/.terraform/**' --exclude '**.terrafor*' -avr \
  -e "ssh -l ${BASTION_USER} ${ADDITIONAL_SSH_OPTS} -p 2222 " \
  ${REPO_ROOT}/ localhost:${REPO_ROOT_DIR}
set +e

if [[ $? != 0 ]]; then
  sleep 5
  echo "    --> Failed to sync ${REPO_ROOT##*/} to bastion attempting a second time"
  rsync --exclude '**/.terraform/**' --exclude '**.terrafor*' -avr \
    -e "ssh -l ${BASTION_USER} ${ADDITIONAL_SSH_OPTS} -p 2222 " \
    ${REPO_ROOT}/ localhost:${REPO_ROOT_DIR}
fi
