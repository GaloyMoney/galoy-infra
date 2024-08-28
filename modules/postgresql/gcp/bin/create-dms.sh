#!/bin/bash
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
echo "Creating migration job '$JOB_NAME' in region '$REGION'..."
gcloud database-migration migration-jobs create "$JOB_NAME" \
    --region="$REGION" \
    --type="$TYPE" \
    --source="$SOURCE_ID" \
    --destination="$DEST_ID" \
    --peer-vpc="$VPC"

if [ $? -eq 0 ]; then
    echo "Migration job '$JOB_NAME' created successfully."
else
    echo "Error: Failed to create migration job '$JOB_NAME'."
    exit 1
fi

# Demote the destination
echo "Demoting the destination for migration job '$JOB_NAME'..."
gcloud database-migration migration-jobs demote-destination "$JOB_NAME" \
    --region="$REGION"

if [ $? -eq 0 ]; then
    echo "Migration job '$JOB_NAME' has started demoting the destination instance."
else
    echo "Error: Failed to demote the destination for migration job '$JOB_NAME'."
    exit 1
fi

# Mention instructions on how to start the DMS
echo -e "\nThe destination instance is being demoted. Run the following command after the process has completed:"
echo -e "\n$ gcloud database-migration migration-jobs start \"$JOB_NAME\" --region=\"$REGION\"\n"