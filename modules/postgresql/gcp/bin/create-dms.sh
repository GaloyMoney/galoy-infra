#!/usr/bin/env bash
set -e

# the directory we want to run the script in
dir=${1}
# the gcp project
PROJECT=${2}
# the gcp region
REGION=${3}
# the migration job name
JOB_NAME=${4}
# tofu output prefix to be used for output automation 
# this is the module name of the current project we are performing migration
OUTPUT_PREFIX=${5}

TYPE="CONTINUOUS"

pushd ${dir}

if [ -z "$PROJECT" ]; then
    echo "Error: PROJECT cannot be empty."
    exit 1
fi
if [ -z "$REGION" ]; then
    echo "Error: REGION cannot be empty."
    exit 1
fi
if [ -z "$JOB_NAME" ]; then
    echo "Error: JOB_NAME cannot be empty."
    exit 1
fi
if [ ! -d "$dir" ]; then
    echo "Error: Directory '$dir' does not exist."
    exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Set the command to use, defaulting to 'terraform' if 'tofu' is not available
if command_exists tofu; then
  cmd="tofu"
else
  cmd="terraform"
fi
# Get Terraform outputs
SOURCE_ID=$($cmd output -raw "${OUTPUT_PREFIX}source_connection_profile_id")
DEST_ID=$($cmd output -raw "${OUTPUT_PREFIX}destination_connection_profile_id")
VPC=$($cmd output -raw "${OUTPUT_PREFIX}vpc")

# Construct and run the gcloud command to create the migration job
echo "Creating migration job '$JOB_NAME' in region '$REGION'..."
gcloud database-migration migration-jobs create "$JOB_NAME" \
    --project="$PROJECT" \
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
    --project="$PROJECT" \
    --region="$REGION"

if [ $? -eq 0 ]; then
    echo "Migration job '$JOB_NAME' has started demoting the destination instance."
else
    echo "Error: Failed to demote the destination for migration job '$JOB_NAME'."
    exit 1
fi

# Mention instructions on how to start the DMS
echo -e "\nThe destination instance is being demoted. Run the following command after the process has completed:"
echo -e "\n$ gcloud database-migration migration-jobs start \"$JOB_NAME\" --project=\"$PROJECT\" --region=\"$REGION\"\n"

popd
