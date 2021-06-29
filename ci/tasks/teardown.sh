#!/bin/bash

set -eu

git_ref="$(cat repo/.git/short_ref)"
pushd repo/examples/gcp

cat <<EOF > ca.cert
${KUBE_CA_CERT}
EOF

kubectl config set-cluster tf-backend --server=${KUBE_HOST} --certificate-authority="$(pwd)/ca.cert"
kubectl config set-credentials tf-backend-user --token=${KUBE_TOKEN}
kubectl config set-context tf-backend --cluster=tf-backend --user=tf-backend-user --namespace concourse-tf
kubectl config use-context tf-backend

cat <<EOF >> bootstrap/main.tf

terraform {
  backend "kubernetes" {
    secret_suffix = "testflight"
    namespace = "concourse-tf"
  }
}
EOF

export KUBE_CONFIG="~/.kube/config"

sed -i'' "s/ref=.*\"/ref=${git_ref}\"/" bootstrap/main.tf

make teardown
