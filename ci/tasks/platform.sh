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

bastion_zone="$(cd inception && tf output bastion_zone | jq -r)"
bastion_name="$(cd inception && tf output bastion_name | jq -r)"

popd

gcloud compute ssh --zone ${bastion_zone} ${bastion_name} --ssh-key-file ${CI_ROOT}/login.ssh \
  --command "mkdir ${CI_ROOT##*/}"
gcloud compute scp --recursive --zone ${bastion_zone} --ssh-key-file ${CI_ROOT}/login.ssh \
  ./repo "${bastion_name}:${CI_ROOT##*/}"
gcloud compute scp --recursive --zone ${bastion_zone} --ssh-key-file ${CI_ROOT}/login.ssh \
  pipeline-tasks "${bastion_name}:${CI_ROOT##*/}"
