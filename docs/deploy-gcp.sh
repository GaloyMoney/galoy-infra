#!/bin/bash

set -e

# Check requirements
if [[ $(which gh) == "" ]] || [[ $(which gcloud) == "" ]] || [[ $(which terraform) == "" ]] || [[ $(which jq) == "" ]]; then
  echo "You will need to install gh, gcloud, jq and terraform to proceed."
  exit 1
fi

# Move to a created folder
TEMP_DIR=$(mktemp -d -p $(pwd) -t infra.XXXXXX)
cd $TEMP_DIR

# Download infra repo and move into GCP example
gh repo clone GaloyMoney/galoy-infra
cd galoy-infra/examples/gcp

# Login to GCloud
gcloud auth login
gcloud auth application-default login

read -p "Do you already have a GCP Project with Billing Setup for this test (Y/n)? [default: n] " HAS_GCP_PROJECT
if [[ $HAS_GCP_PROJECT == "Y" ]]; then
  read -p "Your GCP Project ID: " GCP_PROJECT_ID
  export GCP_PROJECT_ID=$GCP_PROJECT_ID
else
  # Making the project
  export GCP_PROJECT_ID="galoy-infra-test-$(git rev-parse --short HEAD)-$(openssl rand -hex 2)"
  gcloud projects create $GCP_PROJECT_ID --set-as-default

  # Set Billing
  gcloud alpha billing accounts list --uri > /tmp/gcp-billing-accounts
  echo "Your Billing Accounts:"
  cat -n /tmp/gcp-billing-accounts
  read -p "? Account Number: " GCP_BILLING_ACCOUNT
  GCP_BILLING_ACCOUNT=$(sed -n $(echo $GCP_BILLING_ACCOUNT)p /tmp/gcp-billing-accounts | sed 's/.*\/\(.*\)/\1/')
  rm /tmp/gcp-billing-accounts
  echo "Linking $GCP_PROJECT_ID with Billing Account $GCP_BILLING_ACCOUNT"
  gcloud alpha billing projects link $GCP_PROJECT_ID --billing-account $GCP_BILLING_ACCOUNT
fi

# Read some variables
read -p "? Name Prefix: " NAME_PREFIX
read -p "? Your Email Address: " USER_EMAIL

# Terraform Variables
cat <<EOF > bootstrap/terraform.tfvars
name_prefix = "$NAME_PREFIX"
gcp_project = "$GCP_PROJECT_ID"
EOF

cat <<EOF > inception/users.auto.tfvars
users = [
  {
    id        = "user:$USER_EMAIL"
    inception = true
    platform  = true
    logs      = true
  }
]
EOF

# Running Bootstrap stage
echo yes | TF_VAR_tf_state_bucket_force_destroy=true make bootstrap

# Inception stage
./bin/prep-inception.sh
echo yes | GOOGLE_CREDENTIALS=$(cat inception-sa-creds.json) make inception

# Add SSH Key to be able to SSH because OSLogin 2FA is set up on bastion
gcloud compute os-login ssh-keys add --key="$(cat ~/.ssh/id_rsa.pub)"

# Might take some seconds for Computer Instance to enable SSH
echo "Waiting for 60s..."
sleep 60

# Ready bastion with all the files here
export BASTION_USER="$(echo $USER_EMAIL | sed 's/[.@]/_/g')"
export ADDITIONAL_SSH_OPTS="-o StrictHostKeyChecking=no -i ~/.ssh/id_rsa"
export GOOGLE_CREDENTIALS=$(cat inception-sa-creds.json)
./bin/prep-bastion.sh

# Fetch bastion IP
pushd inception
BASTION_IP="$(terraform output bastion_ip | jq -r)"
popd

# SSH and start the platform
ssh $ADDITIONAL_SSH_OPTS $BASTION_USER@$BASTION_IP "\
  cd galoy-infra/examples/gcp; \
  export GOOGLE_APPLICATION_CREDENTIALS=\$(pwd)/inception-sa-creds.json; \
  echo yes | make initial-platform && echo yes | make platform"

echo "Galoy Infra deployment is now complete."
echo "All of your terraform files are available in this folder: $TEMP_DIR"
echo "You can SSH into the Bastion (2FA enabled) using \"ssh $BASTION_USER@$BASTION_IP\""
