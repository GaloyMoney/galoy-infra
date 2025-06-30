#!/bin/bash

echo "    --> prep-postgresql.sh"

set -eu

echo "    --> gathering variables"
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_ROOT_DIR="${REPO_ROOT##*/}"

pushd bootstrap

tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
name_prefix=$(tofu output name_prefix | jq -r)
gcp_project=$(tofu output gcp_project | jq -r)

popd

pushd inception

bastion_name="$(tofu output bastion_name | jq -r)"
bastion_zone="$(tofu output bastion_zone | jq -r)"

echo "    --> results:"
echo "        tf_state_bucket_name: ${tf_state_bucket_name}"
echo "        name_prefix: ${name_prefix}"
echo "        gcp_project: ${gcp_project}"
echo "        bastion_name: ${bastion_name}"
echo "        bastion_zone: ${bastion_zone}"

popd

pushd postgresql

cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/postgresql"
  }
}
EOF

cat <<EOF > terraform.tfvars
gcp_project = "${gcp_project}"
name_prefix = "${name_prefix}"
EOF

popd

echo "    --> starting iap tunnel"

gcloud compute start-iap-tunnel ${bastion_name} --zone=${bastion_zone} 22 --local-host-port=localhost:2222 &
sleep 5
trap 'jobs -p | xargs kill' EXIT

ADDITIONAL_SSH_OPTS=${ADDITIONAL_SSH_OPTS:-""}
echo "    --> Syncing ${REPO_ROOT##*/} to bastion"
rsync --exclude '**/.terraform/**' --exclude '**.terrafor*' -avr -e "ssh -l ${BASTION_USER} ${ADDITIONAL_SSH_OPTS} -p 2222 " \
  ${REPO_ROOT}/ localhost:${REPO_ROOT_DIR}-pg
