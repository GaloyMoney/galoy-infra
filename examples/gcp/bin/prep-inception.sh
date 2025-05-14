#!/bin/bash

set -eu

pushd bootstrap

echo "    --> bootstrap outputs"
tofu output > ../inception/terraform.tfvars

inception_email=$(tofu output inception_sa | jq -r)
echo "    --> inception_email: ${inception_email}"
tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
echo "    --> tf_state_bucket_name: ${tf_state_bucket_name}"
name_prefix=$(tofu output name_prefix | jq -r)
echo "    --> name_prefix: ${name_prefix}"

popd

echo "    --> create inception-sa-creds.json"
gcloud iam service-accounts keys create inception-sa-creds.json \
  --iam-account=${inception_email}

export GOOGLE_CREDENTIALS=$(cat inception-sa-creds.json)

pushd inception

echo "    --> create terraform.tfvars"
cat <<EOF > terraform.tfvars
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/inception"
  }
}
EOF

echo "    --> Wait for the service account key to propagate"
sleep 5

echo "    --> tofu init"
tofu init

echo "    --> tofu state show module.inception.google_project_iam_custom_role.inception_destroy || tofu apply ..."
tofu state show module.inception.google_project_iam_custom_role.inception_destroy || \
  tofu apply \
    -target module.inception.google_project_iam_custom_role.inception_make \
    -target module.inception.google_project_iam_custom_role.inception_destroy \
    -target module.inception.google_project_iam_member.inception_make \
    -target module.inception.google_project_iam_member.inception_destroy \
    -auto-approve

echo "    --> end prep-inception.sh"
