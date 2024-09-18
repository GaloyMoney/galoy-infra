#!/bin/bash

set -eu

pushd bootstrap

terraform output > ../inception/terraform.tfvars

inception_email=$(terraform output inception_sa | jq -r)
tf_state_bucket_name=$(terraform output tf_state_bucket_name | jq -r)
name_prefix=$(terraform output name_prefix | jq -r)

popd

gcloud iam service-accounts keys create inception-sa-creds.json \
  --iam-account=${inception_email}

export GOOGLE_CREDENTIALS=$(cat inception-sa-creds.json)

pushd inception

cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/inception"
  }
}
EOF

# Wait for the service account key to propagate
sleep 5

terraform init
terraform state show module.inception.google_storage_bucket.tf_state

terraform state show module.inception.google_project_iam_custom_role.inception_destroy || \
  terraform apply \
    -target module.inception.google_project_iam_custom_role.inception_make \
    -target module.inception.google_project_iam_custom_role.inception_destroy \
    -target module.inception.google_project_iam_member.inception_make \
    -target module.inception.google_project_iam_member.inception_destroy \
    -auto-approve

