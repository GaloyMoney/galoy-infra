set -euo pipefail

pushd bootstrap >/dev/null

terraform output -json \
  | jq -r 'to_entries[] | 
      "\(.key) = \"\(.value.value)\""' \
  > ../inception/terraform.tfvars

bucket_name=$(jq -r '.tf_state_bucket_name.value' < ../inception/terraform.tfvars)
lock_table=$(jq -r '.tf_lock_table_name.value'   < ../inception/terraform.tfvars)
region=$(jq -r '.aws_region.value'               < ../inception/terraform.tfvars)
prefix=$(jq -r '.name_prefix.value'              < ../inception/terraform.tfvars)

popd >/dev/null

cat > inception/backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "${bucket_name}"
    key            = "${prefix}/inception.tfstate"
    region         = "${region}"
    dynamodb_table = "${lock_table}"
    encrypt        = true
  }
}
EOF

pushd inception >/dev/null
terraform init
popd >/dev/null

echo " Inception tfvars and backend have been written, and terraform init completed."
