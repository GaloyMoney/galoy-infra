#!/bin/bash
# This script prepares the inception phase by:
# 1. Extracting outputs from bootstrap
# 2. Switching to the IAM role created in bootstrap for inception permissions
# 3. Creating Terraform configuration files with proper backend settings
#
# IMPORTANT: This script must be run with an IAM user, NOT a root account

set -eu

# Function to handle errors
error_exit() {
  echo "ERROR: $1" >&2
  exit 1
}

# Get caller identity before making any changes
account_id=$(aws sts get-caller-identity --query 'Account' --output text)
caller_arn=$(aws sts get-caller-identity --query 'Arn' --output text)

# Verify not using root account
if [[ "$caller_arn" == *":root"* ]]; then
  error_exit "This script must be run with an IAM user, not the root account. Please create an IAM user with appropriate permissions."
fi

echo "Running as IAM identity: $caller_arn"
echo "Extracting bootstrap outputs..."

pushd bootstrap

# Export terraform outputs to inception tfvars file
tofu output | grep -v sensitive > ../inception/terraform.tfvars

# Extract variables needed for backend configuration
tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
tf_lock_table_name=$(tofu output tf_lock_table_name | jq -r)
aws_region=$(tofu output aws_region | jq -r)
name_prefix=$(tofu output name_prefix | jq -r)
inception_role_arn=$(tofu output inception_role_arn | jq -r)

popd

echo "Assuming inception role: $inception_role_arn"

# Assume the inception role
temp_creds=$(aws sts assume-role \
  --role-arn ${inception_role_arn} \
  --role-session-name inception-setup \
  --query 'Credentials' \
  --output json) || error_exit "Failed to assume the inception role"

# Extract and verify credentials
AWS_ACCESS_KEY_ID=$(echo $temp_creds | jq -r '.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $temp_creds | jq -r '.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo $temp_creds | jq -r '.SessionToken')

# Verify we have valid credentials
if [[ -z "$AWS_ACCESS_KEY_ID" || "$AWS_ACCESS_KEY_ID" == "null" ]]; then
  error_exit "Failed to get valid credentials from assumed role"
fi

# Export credentials for Terraform to use
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

# Verify the role assumption worked
echo "Verifying role assumption..."
assumed_arn=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
              AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
              AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
              aws sts get-caller-identity --query 'Arn' --output text)

echo "Successfully assumed role: $assumed_arn"

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
    key            = "${name_prefix}/inception.tfstate"
    region         = "${aws_region}"
    dynamodb_table = "${tf_lock_table_name}"
    encrypt        = true
  }
}
EOF

echo "Initializing Terraform..."
tofu init -migrate-state

popd

echo "Inception preparation complete! The script has:"
echo "1. Created terraform.tfvars with bootstrap outputs"
echo "2. Created terraform.tf with S3 backend configuration"
echo "3. Successfully assumed the inception IAM role: $(echo $assumed_arn | cut -d/ -f2)"
echo "4. Initialized Terraform in the inception directory"
