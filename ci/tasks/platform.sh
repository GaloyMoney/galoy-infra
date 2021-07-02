#!/bin/bash

set -eu

source pipeline-tasks/ci/tasks/helpers.sh

pushd repo/examples/gcp

update_examples_git_ref

init_gcloud

init_kubeconfig
init_bootstrap

write_users

bin/prep-inception.sh

bastion_zone="$(cd inception && terraform output bastion_zone | jq -r)"
bastion_ip="$(cd inception && terraform output bastion_ip | jq -r)"
bastion_name="$(cd inception && terraform output bastion_name | jq -r)"

set +e
for i in {1..10}; do
  echo "Attempt ${i} to ssh to bastion"
  gcloud compute ssh --zone ${bastion_zone} ${bastion_name} --ssh-key-file ${CI_ROOT}/login.ssh \
  --command "ls ${CI_ROOT_DIR} || mkdir ${CI_ROOT_DIR}" && break
  sleep 1
done
set -e

export REMOTE_FOLDER="${CI_ROOT_DIR}/repo"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-i ${CI_ROOT}/login.ssh"
bin/prep-bastion.sh

popd

echo "Syncing pipeline-tasks to bastion"

rsync -avr -e "ssh -l ${BASTION_USER} -o StrictHostKeyChecking=no ${ADDITIONAL_SSH_OPTS}" \
  pipeline-tasks ${bastion_ip}:${REMOTE_FOLDER}/pipeline-tasks > /dev/null
