#!/bin/bash

set -eu

pushd repo/examples/gcp

cat <<EOF > ca.cert
${KUBE_CA_CERT}
EOF

kubectl config set-cluster tf-backend --server=${KUBE_HOST} --certificate-authority="$(pwd)/ca.cert"
kubectl config set-credentials tf-backend-user --token=${KUBE_TOKEN}
kubectl config set-context tf-backend --cluster=tf-backend --user=tf-backend-user --namespace tf-backend
kubectl config use-context tf-backend

cat <<EOF >> bootstrap/main.tf

terraform {
  backend "kubernetes" {
    secret_suffix = "testflight"
  }
}
EOF

export KUBE_CONFIG="~/.kube/config"

terraform init
export TF_VAR_name_prefix=testflight
make teardown-bootstrap
