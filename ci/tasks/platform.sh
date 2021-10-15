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
cleanup_inception_key

bastion_ip="$(cd inception && terraform output bastion_ip | jq -r)"
export BASTION_USER="sa_$(cat ${CI_ROOT}/gcloud-creds.json  | jq -r '.client_id')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ${CI_ROOT}/login.ssh"

gcloud compute os-login ssh-keys add --key-file=${CI_ROOT}/login.ssh.pub

set +e
for i in {1..60}; do
  echo "Attempt ${i} to find make on bastion"
  ssh ${ADDITIONAL_SSH_OPTS} ${BASTION_USER}@${bastion_ip} "which make" && break
  sleep 2
done
set -e


cat <<EOF > platform/additional.auto.tfvars
letsencrypt_issuer_email  = "bot@galoy.io"
node_default_machine_type = "e2-small"
EOF

cp ${CI_ROOT}/gcloud-cerds.json ./

bin/prep-bastion.sh

ssh ${ADDITIONAL_SSH_OPTS} ${BASTION_USER}@${bastion_ip} "cd repo/examples/gcp; gcloud auth activate-service-account --key-file ./gcloud-creds.json; echo yes | make initial-platform && echo yes | make platform"
