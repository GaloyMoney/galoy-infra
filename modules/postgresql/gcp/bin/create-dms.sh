#!/bin/bash

set -x

TYPE="CONTINUOUS"

# Get user input for region and job name
read -p "Enter the region: " REGION
read -p "Enter the job name: " JOB_NAME

# Validate user input
if [ -z "$REGION" ] || [ -z "$JOB_NAME" ]; then
    echo "Error: Region and job name cannot be empty."
    exit 1
fi

# Get Terraform outputs
SOURCE_ID=$(terraform output -raw source_connection_profile_id)
DEST_ID=$(terraform output -raw destination_connection_profile_id)
VPC=$(terraform output -raw vpc)

# Construct and run the gcloud command to create the migration job
gcloud database-migration migration-jobs create "$JOB_NAME" \
    --region="$REGION" \
    --type="$TYPE" \
    --source="$SOURCE_ID" \
    --destination="$DEST_ID" \
    --peer-vpc="$VPC"

echo "Migration job '$JOB_NAME' created successfully."

# Demote the destination
gcloud database-migration migration-jobs demote-destination "$JOB_NAME" \
    --region="$REGION"

echo "Migration job '$JOB_NAME' demoted the destination successfully."

# Start the DMS
gcloud database-migration migration-jobs start "$JOB_NAME" \
    --region="$REGION"

echo "Migration job '$JOB_NAME' has started."

set +x
