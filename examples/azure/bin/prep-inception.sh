#!/bin/bash

set -eu

pushd bootstrap

terraform output > ../inception/terraform.tfvars

tenant_id
tf_state_bucket_name=$(terraform output tf_state_bucket_name | jq -r)
name_prefix=$(terraform output name_prefix | jq -r)

popd

gcloud iam service-accounts keys create inception-sa-creds.json \
  --iam-account=${inception_email}

export ARM_CLIENT_ID = #@ data.values.testflight_azure_client_id
export ARM_CLIENT_SECRET = #@ data.values.testflight_azure_client_secret
#export ARM_TENANT_ID = #@ data.values.testflight_azure_tenant_id
#export ARM_SUBSCRIPTION_ID = 
pushd inception

cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/inception"
  }
}
EOF

terraform init
terraform state show module.inception.google_storage_bucket.tf_state || \
  terraform import module.inception.google_storage_bucket.tf_state ${tf_state_bucket_name}
terraform apply \
  -target module.inception.google_project_iam_custom_role.inception_make \
  -target module.inception.google_project_iam_custom_role.inception_destroy \
  -target module.inception.google_project_iam_member.inception_make \
  -target module.inception.google_project_iam_member.inception_destroy \
  -auto-approve

