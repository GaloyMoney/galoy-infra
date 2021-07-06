#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

init_gcloud
gcloud compute os-login ssh-keys add --key-file=${CI_ROOT}/login.ssh.pub

pushd repo/gcp/staging

pushd inception
cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${BUCKET}"
    prefix = "galoy-staging/inception"
  }
}
EOF
bastion_ip="$(cd inception && terraform output bastion_ip | jq -r)"
popd

export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

set +e
for i in {1..60}; do
  echo "Attempt ${i} to find make on bastion"
  ssh ${ADDITIONAL_SSH_OPTS} ${BASTION_USER}@${bastion_ip} "which make" && break
  sleep 2
done
set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_ROOT_DIR="${REPO_ROOT##*/}"
echo "Syncing ${REPO_ROOT##*/} to bastion"
rsync -avr -e "ssh -l ${BASTION_USER} ${ADDITIONAL_SSH_OPTS}" \
  ${REPO_ROOT}/ ${bastion_ip}:${REPO_ROOT_DIR} > /dev/null

echo "Executing terraform"
ssh ${ADDITIONAL_SSH_OPTS} ${BASTION_USER}@${bastion_ip} \
  "cd ${REPO_ROOT_DIR}/staging/gcplatform; terraform init && terraform apply -auto-aprove"
