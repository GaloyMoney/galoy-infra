#!/bin/bash

set -eu

# Function to handle errors
error_exit() {
  echo "ERROR: $1" >&2
  exit 1
}

pushd bootstrap

caller_arn=$(aws sts get-caller-identity --query 'Arn' --output text)

tofu output | grep -v sensitive > ../inception/terraform.tfvars

tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
tf_lock_table_name=$(tofu output tf_lock_table_name | jq -r)
aws_region=$(tofu output aws_region | jq -r)
name_prefix=$(tofu output name_prefix | jq -r)
inception_role_arn=$(tofu output inception_role_arn | jq -r)

popd

if [[ "$caller_arn" != *"$name_prefix-inception-tf"* ]]; then
  echo "Assuming inception role: $inception_role_arn"

  temp_creds=$(aws sts assume-role \
    --role-arn ${inception_role_arn} \
    --role-session-name inception-setup \
    --query 'Credentials' \
    --output json) || error_exit "Failed to assume the inception role"

  AWS_ACCESS_KEY_ID=$(echo $temp_creds | jq -r '.AccessKeyId')
  AWS_SECRET_ACCESS_KEY=$(echo $temp_creds | jq -r '.SecretAccessKey')
  AWS_SESSION_TOKEN=$(echo $temp_creds | jq -r '.SessionToken')

  if [[ -z "$AWS_ACCESS_KEY_ID" || "$AWS_ACCESS_KEY_ID" == "null" ]]; then
    error_exit "Failed to get valid credentials from assumed role"
  fi

  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_SESSION_TOKEN

  echo "Verifying role assumption..."
  assumed_arn=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
                AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
                AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
                aws sts get-caller-identity --query 'Arn' --output text)

  echo "Successfully assumed role: $assumed_arn"
else
  echo "Already using inception role, skipping role assumption"
fi

pushd inception

echo "Creating Terraform configuration files..."

cat <<EOF > terraform.tfvars
name_prefix = "${name_prefix}"
aws_region = "${aws_region}"
EOF

cat <<EOF > terraform.tf
terraform {
  backend "s3" {
    bucket         = "${tf_state_bucket_name}"
    key            = "${name_prefix}/inception/terraform.tfstate"
    region         = "${aws_region}"
    dynamodb_table = "${tf_lock_table_name}"
    encrypt        = true
  }
}
EOF

echo "Initializing Terraform..."
tofu init -migrate-state

popd


