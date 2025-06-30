#!/bin/bash
# scrub_project.sh - Script to clean up GCP resources with "testflight0" prefix
#
# This script removes only resources that start with "testflight0" from a GCP project.
# This approach is safer and simpler than trying to exclude system resources.
#
# Usage: ./scrub_project.sh PROJECT_ID [--dry-run] [--no-ask] [--prefix PREFIX]
#   --dry-run: Show what would be deleted without actually deleting
#   --no-ask: Skip confirmation prompts (use with caution!)
#   --prefix: Resource name prefix to target (default: testflight0)

set -e

# Default values
DRY_RUN=false
NO_ASK=false
PROJECT_ID=""
PREFIX="testflight0"

# Text formatting
BOLD='\033[1m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --no-ask)
      NO_ASK=true
      shift
      ;;
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    *)
      if [[ -z "$PROJECT_ID" ]]; then
        PROJECT_ID="$1"
      else
        echo -e "${RED}Error: Unknown parameter $1${NC}"
        echo "Usage: ./scrub_project.sh PROJECT_ID [--dry-run] [--no-ask] [--prefix PREFIX]"
        exit 1
      fi
      shift
      ;;
  esac
done

# Validate project ID
if [[ -z "$PROJECT_ID" ]]; then
  echo -e "${RED}Error: PROJECT_ID is required${NC}"
  echo "Usage: ./scrub_project.sh PROJECT_ID [--dry-run] [--no-ask] [--prefix PREFIX] [--delete-all-buckets]"
  exit 1
fi

# Safety check: only allow infra-testflight project
if [[ "$PROJECT_ID" != "infra-testflight" ]]; then
  echo -e "${RED}Error: This script is only allowed to run on the 'infra-testflight' project for safety.${NC}"
  echo -e "${RED}Provided project: $PROJECT_ID${NC}"
  echo -e "${YELLOW}If you need to clean up a different project, please modify this safety check.${NC}"
  exit 1
fi

# Check if project exists
if ! gcloud projects describe "$PROJECT_ID" &>/dev/null; then
  echo -e "${RED}Error: Project $PROJECT_ID does not exist or you don't have access to it${NC}"
  exit 1
fi

# Function to execute or echo command based on dry run flag
execute() {
  local suppress_output=false
  if [[ "$1" == "--suppress-output" ]]; then
    suppress_output=true
    shift
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}Would execute:${NC} $*"
    return 0
  else
    echo -e "${GREEN}Executing:${NC} $*"
    eval "$*"
    return $?
  fi
}

# Function to ask for confirmation
confirm() {
  if [[ "$NO_ASK" == true ]]; then
    return 0
  fi

  read -p "$1 (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}

# Function to check and delete resources with prefix filtering
check_and_delete_resources() {
  local resource_type=$1
  local list_command=$2
  local delete_command=$3
  local resource_name_field=${4:-1}
  local resource_location_field=${5:-""}
  local resource_location_type=${6:-""}

  echo -e "\n${BOLD}Checking for ${resource_type} with prefix '${PREFIX}'...${NC}"
  local resources
  resources=$(eval "$list_command" 2>/dev/null || echo "")

  if [[ -n "$resources" ]]; then
    # Filter resources that start with our prefix
    local matching_resources=""
    while read -r line; do
      if [[ -n "$line" ]]; then
        local name
        name=$(echo "$line" | awk "{print \$$resource_name_field}")
        if [[ "$name" == "$PREFIX"* ]]; then
          matching_resources+="$line"$'\n'

          # Display resource info
          if [[ -n "$resource_location_field" ]]; then
            local location
            location=$(echo "$line" | awk "{print \$$resource_location_field}")
            echo "- $name (${resource_location_type}: $location)"
          else
            echo "- $name"
          fi
        fi
      fi
    done <<< "$resources"

    # Trim trailing newline
    matching_resources=$(echo "$matching_resources" | sed '/^$/d')

    if [[ -n "$matching_resources" ]]; then
      if confirm "Delete these ${resource_type}?"; then
        while read -r line; do
          if [[ -n "$line" ]]; then
            local name
            name=$(echo "$line" | awk "{print \$$resource_name_field}")
            local delete_cmd="$delete_command"

            if [[ -n "$resource_location_field" ]]; then
              local location
              location=$(echo "$line" | awk "{print \$$resource_location_field}")
              delete_cmd="${delete_cmd//%LOCATION%/$location}"
            fi

            delete_cmd="${delete_cmd//%NAME%/$name}"
            execute "$delete_cmd"
          fi
        done <<< "$matching_resources"
      fi
    else
      echo "No ${resource_type} found with prefix '${PREFIX}'."
    fi
  else
    echo "No ${resource_type} found."
  fi
}

# Function to handle VPC networks and their dependencies
delete_vpc_networks() {
  echo -e "\n${BOLD}Checking for VPC networks with prefix '${PREFIX}'...${NC}"
  local networks
  networks=$(gcloud compute networks list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null || echo "")

  if [[ -n "$networks" ]]; then
    # Filter networks that start with our prefix
    local matching_networks=()

    for network in $networks; do
      if [[ "$network" == "$PREFIX"* ]]; then
        matching_networks+=("$network")
      fi
    done

    if [[ ${#matching_networks[@]} -gt 0 ]]; then
      echo "Found VPC networks:"
      for network in "${matching_networks[@]}"; do
        echo "- $network"

        # List subnets for this network
        local subnets
        subnets=$(gcloud compute networks subnets list --network="$network" --project="$PROJECT_ID" --format="value(name,region)" 2>/dev/null || echo "")
        if [[ -n "$subnets" ]]; then
          echo "  Subnets:"
          echo "$subnets" | while read -r name region; do
            echo "  - $name (region: $region)"
          done
        fi
      done

      if confirm "Delete these VPC networks and their subnets?"; then
        for network in "${matching_networks[@]}"; do
          # Delete subnets first
          local subnets
          subnets=$(gcloud compute networks subnets list --network="$network" --project="$PROJECT_ID" --format="value(name,region)" 2>/dev/null || echo "")
          if [[ -n "$subnets" ]]; then
            echo "$subnets" | while read -r name region; do
              execute "gcloud compute networks subnets delete $name --region=$region --quiet --project=$PROJECT_ID"
            done
          fi

          # Then delete the network
          execute "gcloud compute networks delete $network --quiet --project=$PROJECT_ID"
        done
      fi
    else
      echo "No VPC networks found with prefix '${PREFIX}'."
    fi
  else
    echo "No VPC networks found."
  fi
}

# Print script mode
if [[ "$DRY_RUN" == true ]]; then
  echo -e "${BOLD}Running in DRY RUN mode. No resources will be deleted.${NC}"
else
  echo -e "${BOLD}${RED}WARNING: This will DELETE resources with prefix '${PREFIX}' in project: $PROJECT_ID${NC}"
  if ! confirm "Are you sure you want to continue?"; then
    echo "Operation cancelled."
    exit 0
  fi
fi

# Main script execution flow
echo -e "${BOLD}Starting cleanup of resources with prefix '${PREFIX}' in project: $PROJECT_ID${NC}"

# 1. GKE Clusters
check_and_delete_resources \
  "GKE clusters" \
  "gcloud container clusters list --project=\"$PROJECT_ID\" --format=\"value(name,zone)\"" \
  "gcloud container clusters delete %NAME% --zone=%LOCATION% --quiet --project=$PROJECT_ID" \
  "1" "2" "zone"

# 2. Cloud SQL Instances
check_and_delete_resources \
  "Cloud SQL instances" \
  "gcloud sql instances list --project=\"$PROJECT_ID\" --format=\"value(name)\"" \
  "gcloud sql instances delete %NAME% --quiet --project=$PROJECT_ID"

# 3. Compute Instances
check_and_delete_resources \
  "Compute instances" \
  "gcloud compute instances list --project=\"$PROJECT_ID\" --format=\"value(name,zone)\"" \
  "gcloud compute instances delete %NAME% --zone=%LOCATION% --quiet --project=$PROJECT_ID" \
  "1" "2" "zone"

# 4. Firewall Rules
check_and_delete_resources \
  "Firewall rules" \
  "gcloud compute firewall-rules list --project=\"$PROJECT_ID\" --format=\"value(name)\"" \
  "gcloud compute firewall-rules delete %NAME% --quiet --project=$PROJECT_ID"

# 5. VPC Peering connections
echo -e "\n${BOLD}Checking for VPC Peering connections with prefix '${PREFIX}'...${NC}"
PEERINGS=$(gcloud compute networks peerings list --project="$PROJECT_ID" --format="csv(name,network)" 2>/dev/null | tail -n +2 || echo "")

if [[ -n "$PEERINGS" ]]; then
  MATCHING_PEERINGS=""

  while IFS=, read -r NAME NETWORK; do
    # Extract just the network name from the full path
    NETWORK_NAME=$(echo "$NETWORK" | sed -E 's/.*\/([^\/]+)$/\1/')
    if [[ "$NETWORK_NAME" == "$PREFIX"* ]]; then
      MATCHING_PEERINGS+="$NAME,$NETWORK"$'\n'
      echo "- $NAME (network: $NETWORK_NAME)"
    fi
  done <<< "$PEERINGS"

  MATCHING_PEERINGS=$(echo "$MATCHING_PEERINGS" | sed '/^$/d')

  if [[ -n "$MATCHING_PEERINGS" ]]; then
    if confirm "Delete these VPC Peering connections?"; then
      while IFS=, read -r NAME NETWORK; do
        # Extract just the network name from the full path
        NETWORK_NAME=$(echo "$NETWORK" | sed -E 's/.*\/([^\/]+)$/\1/')
        if [[ -n "$NETWORK_NAME" ]]; then
          execute "gcloud compute networks peerings delete $NAME --network=$NETWORK_NAME --quiet --project=$PROJECT_ID"
        else
          echo -e "${YELLOW}Skipping peering $NAME due to missing network name${NC}"
        fi
      done <<< "$MATCHING_PEERINGS"
    fi
  else
    echo "No VPC Peering connections found with prefix '${PREFIX}'."
  fi
else
  echo "No VPC Peering connections found."
fi

# 6. Service Networking connections (only for networks with our prefix)
echo -e "\n${BOLD}Checking for Service Networking connections in networks with prefix '${PREFIX}'...${NC}"
NETWORKS=$(gcloud compute networks list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null || echo "")
FOUND_SERVICENETWORKING=false

for NETWORK in $NETWORKS; do
  if [[ "$NETWORK" == "$PREFIX"* ]]; then
    FOUND_SERVICENETWORKING=true
    echo "Checking network: $NETWORK"
    execute "gcloud compute networks peerings delete servicenetworking-googleapis-com --network=$NETWORK --quiet --project=$PROJECT_ID" || true
  fi
done

if [[ "$FOUND_SERVICENETWORKING" == false ]]; then
  echo "No networks found with prefix '${PREFIX}' to check for service networking connections."
fi

# 7. Global Addresses (used for peering)
check_and_delete_resources \
  "Global Addresses" \
  "gcloud compute addresses list --project=\"$PROJECT_ID\" --global --format=\"value(name)\"" \
  "gcloud compute addresses delete %NAME% --global --quiet --project=$PROJECT_ID"

# 8. Cloud Routers
check_and_delete_resources \
  "Cloud Routers" \
  "gcloud compute routers list --project=\"$PROJECT_ID\" --format=\"value(name,region)\"" \
  "gcloud compute routers delete %NAME% --region=%LOCATION% --quiet --project=$PROJECT_ID" \
  "1" "2" "region"

# 9. VPC Networks and Subnets
delete_vpc_networks

# 10. Cloud Storage Buckets
delete_storage_buckets() {
  echo -e "\n${BOLD}Checking for Storage buckets with prefix '${PREFIX}'...${NC}"
  local buckets
  buckets=$(gsutil ls -p "$PROJECT_ID" 2>/dev/null | sed 's|gs://||g' | sed 's|/$||g' || echo "")

  if [[ -n "$buckets" ]]; then
    # Filter buckets that start with our prefix
    local matching_buckets=()

    for bucket in $buckets; do
      if [[ "$bucket" == "$PREFIX"* ]]; then
        matching_buckets+=("$bucket")
      fi
    done

    if [[ ${#matching_buckets[@]} -gt 0 ]]; then
      echo "Found Storage buckets:"
      for bucket in "${matching_buckets[@]}"; do
        echo "- $bucket"
      done

      if confirm "Delete these Storage buckets and all their contents?"; then
        for bucket in "${matching_buckets[@]}"; do
          execute "gsutil rb -f gs://$bucket"
        done
      fi
    else
      echo "No Storage buckets found with prefix '${PREFIX}'."
    fi
  else
    echo "No Storage buckets found."
  fi
}

delete_storage_buckets

# 11. Pub/Sub Topics
check_and_delete_resources \
  "Pub/Sub topics" \
  "gcloud pubsub topics list --project=\"$PROJECT_ID\" --format=\"value(name)\"" \
  "gcloud pubsub topics delete %NAME% --project=$PROJECT_ID"

# 12. Load Balancers and Forwarding Rules
check_and_delete_resources \
  "Forwarding Rules" \
  "gcloud compute forwarding-rules list --project=\"$PROJECT_ID\" --format=\"value(name,region)\"" \
  "gcloud compute forwarding-rules delete %NAME% --region=%LOCATION% --quiet --project=$PROJECT_ID" \
  "1" "2" "region"

# 13. Service Accounts (delete after resources that use them)
check_and_delete_resources \
  "Service accounts" \
  "gcloud iam service-accounts list --project=\"$PROJECT_ID\" --format=\"value(email)\"" \
  "gcloud iam service-accounts delete %NAME% --quiet --project=$PROJECT_ID"

# 14. Custom IAM Roles
echo -e "\n${BOLD}Checking for Custom IAM Roles with prefix '${PREFIX}'...${NC}"
CUSTOM_ROLES=$(gcloud iam roles list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null || echo "")
if [[ -n "$CUSTOM_ROLES" ]]; then
  echo "Found Custom IAM Roles:"
  MATCHING_ROLES=()

  while read -r ROLE_PATH; do
    ROLE_NAME=${ROLE_PATH#"projects/$PROJECT_ID/roles/"}

    # Only include roles that start with our prefix
    if [[ "$ROLE_NAME" == "$PREFIX"* ]]; then
      echo -e "- ${ROLE_NAME}"
      MATCHING_ROLES+=("$ROLE_NAME")
    fi
  done <<< "$CUSTOM_ROLES"

  if [[ ${#MATCHING_ROLES[@]} -gt 0 ]]; then
    if confirm "Delete these ${#MATCHING_ROLES[@]} Custom IAM Roles with prefix '${PREFIX}'?"; then
      for ROLE_NAME in "${MATCHING_ROLES[@]}"; do
        execute "gcloud iam roles delete \"$ROLE_NAME\" --project=\"$PROJECT_ID\" --quiet"
        echo -e "${GREEN}Deleted role:${NC} $ROLE_NAME"
      done
    fi
  else
    echo "No Custom IAM Roles found with prefix '${PREFIX}'."
  fi
else
  echo "No Custom IAM Roles found."
fi

echo -e "\n${BOLD}Note:${NC} Soft-deleted IAM roles will be automatically purged after 7 days."
echo "This script will not attempt to recover or modify soft-deleted roles."

echo -e "\n${BOLD}Project cleanup process completed for resources with prefix '${PREFIX}'.${NC}"
if [[ "$DRY_RUN" == true ]]; then
  echo -e "${YELLOW}This was a dry run. No resources were actually deleted.${NC}"
  echo "To actually delete resources, run without the --dry-run flag."
else
  echo -e "${GREEN}All matching resources have been processed.${NC}"
  echo "Note: Some resources may take a few minutes to be fully deleted."
fi
