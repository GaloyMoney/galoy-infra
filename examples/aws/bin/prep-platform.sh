#!/bin/bash

set -eu

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_ROOT_DIR="${REPO_ROOT##*/}"

pushd bootstrap
tf_state_bucket=$(tofu output -json tf_state_bucket_name | jq -r)
name_prefix=$(tofu output -json name_prefix | jq -r)
aws_region=$(tofu output -json aws_region | jq -r)
inception_role_arn=$(tofu output -json inception_role_arn | jq -r)
tf_lock_table=$(tofu output -json tf_lock_table_name | jq -r)
popd

echo "Assuming inception role: $inception_role_arn"
temp_creds=$(aws sts assume-role \
  --role-arn ${inception_role_arn} \
  --role-session-name platform-setup \
  --query 'Credentials' \
  --output json)

export AWS_ACCESS_KEY_ID=$(echo $temp_creds | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $temp_creds | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $temp_creds | jq -r '.SessionToken')

assumed_arn=$(aws sts get-caller-identity --query 'Arn' --output text)
echo "Successfully assumed role: $assumed_arn"

pushd inception
eks_cluster_role_arn=$(tofu output -json eks_cluster_role_arn | jq -r)
eks_nodes_role_arn=$(tofu output -json eks_nodes_role_arn | jq -r)
nat_gateway_ids=$(tofu output -json nat_gateway_ids)
popd

pushd platform

cat <<EOF > terraform.tf
terraform {
  backend "s3" {
    bucket         = "${tf_state_bucket}"
    key            = "${name_prefix}/platform/terraform.tfstate"
    region         = "${aws_region}"
    dynamodb_table = "${tf_lock_table}"
    encrypt        = true
  }
}
EOF

cat <<EOF > terraform.tfvars
name_prefix = "${name_prefix}"
aws_region = "${aws_region}"
eks_cluster_role_arn = "${eks_cluster_role_arn}"
eks_nodes_role_arn = "${eks_nodes_role_arn}"
inception_state_backend = {
  bucket         = "${tf_state_bucket}"
  key            = "${name_prefix}/inception/terraform.tfstate"
  region         = "${aws_region}"
  dynamodb_table = "${tf_lock_table}"
}
EOF

tofu init
popd 
