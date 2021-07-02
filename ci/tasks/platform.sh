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
export REMOTE_FOLDER="${CI_ROOT_DIR}/repo"
bin/prep-bastion.sh

popd

rsync -avr -e "ssh -l ${BASTION_USER} -o StrictHostKeyChecking=no" pipeline-tasks ${bastion_ip}:${REMOTE_FOLDER}/pipeline-tasks
