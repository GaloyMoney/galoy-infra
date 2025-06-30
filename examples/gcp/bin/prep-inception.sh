#!/bin/bash

echo "    --> prep-inception.sh"

set -eu

pushd bootstrap

echo "    --> bootstrap outputs"
tofu output > ../inception/terraform.tfvars
inception_email=$(tofu output inception_sa | jq -r)
tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
name_prefix=$(tofu output name_prefix | jq -r)
echo "    --> results:"
echo "        inception_email: ${inception_email}"
echo "        tf_state_bucket_name: ${tf_state_bucket_name}"
echo "        name_prefix: ${name_prefix}"

popd

echo "    --> create inception-sa-creds.json"
echo "        FAILED_PRECONDITION means you reached the quota for service account keys"
gcloud iam service-accounts keys create inception-sa-creds.json \
  --iam-account=${inception_email}

# Validate the JSON key file was created properly
if ! jq empty inception-sa-creds.json 2>/dev/null; then
  echo "    --> ERROR: inception-sa-creds.json is not valid JSON"
  echo "    --> File contents: $(cat inception-sa-creds.json)"
  exit 1
fi

SERVICE_ACCOUNT=$(jq -r '.client_email' inception-sa-creds.json)
export SERVICE_ACCOUNT
GOOGLE_CREDENTIALS=$(< inception-sa-creds.json)
export GOOGLE_CREDENTIALS

echo "    --> Service account: $SERVICE_ACCOUNT"

pushd inception

echo "    --> create terraform.tf"
cat <<EOF > terraform.tf
terraform {
  backend "gcs" {
    bucket = "${tf_state_bucket_name}"
    prefix = "${name_prefix}/inception"
  }
}
EOF

echo "    --> Validating service account key (up to 60 secs, checking every 10 secs)"
validation_attempts=0
max_attempts=6  # 6 attempts * 10 seconds = 60 seconds

while [ $validation_attempts -lt $max_attempts ]; do
  validation_attempts=$((validation_attempts + 1))
  echo "    --> Validation attempt $validation_attempts/$max_attempts"

  # Test the service account key by trying to authenticate and get token info
  if GOOGLE_APPLICATION_CREDENTIALS=../inception-sa-creds.json gcloud auth application-default print-access-token --quiet > /dev/null 2>&1; then
    echo "    --> Service account key validation successful"
    break
  else
    if [ $validation_attempts -eq $max_attempts ]; then
      echo "    --> ERROR: Service account key validation failed after $max_attempts attempts"
      echo "    --> Key file contents (first 100 chars): $(head -c 100 ../inception-sa-creds.json)"
      exit 1
    else
      echo "    --> Key not ready yet, waiting 10 seconds..."
      sleep 10
    fi
  fi
done

echo "    --> tofu init with SERVICE_ACCOUNT $SERVICE_ACCOUNT"
# Retry tofu init up to 3 times in case of authentication issues
init_attempts=0
max_init_attempts=3

while [ $init_attempts -lt $max_init_attempts ]; do
  init_attempts=$((init_attempts + 1))
  echo "    --> tofu init attempt $init_attempts/$max_init_attempts"

  if tofu init; then
    echo "    --> tofu init successful"
    break
  else
    if [ $init_attempts -eq $max_init_attempts ]; then
      echo "    --> ERROR: tofu init failed after $max_init_attempts attempts"
      exit 1
    else
      echo "    --> tofu init failed, waiting 5 seconds before retry..."
      sleep 5
    fi
  fi
done

echo "    --> tofu state show module.inception.google_project_iam_custom_role.inception_destroy || tofu apply ..."
tofu state show module.inception.google_project_iam_custom_role.inception_destroy || \
  tofu apply \
    -target module.inception.google_project_iam_custom_role.inception_make \
    -target module.inception.google_project_iam_custom_role.inception_destroy \
    -target module.inception.google_project_iam_member.inception_make \
    -target module.inception.google_project_iam_member.inception_destroy \
    -auto-approve

echo "    --> end prep-inception.sh"
