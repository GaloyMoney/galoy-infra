#!/bin/bash
# scrub_project.sh - Script to clean up GCP resources
#
# This script removes all resources from a GCP project to return it to a clean state.
# It's particularly useful when Terraform state doesn't match actual resources.
#
# Usage: ./scrub_project.sh PROJECT_ID [--dry-run] [--no-ask]
#   --dry-run: Show what would be deleted without actually deleting
#   --no-ask: Skip confirmation prompts (use with caution!)

set -e

# Default values
DRY_RUN=false
NO_ASK=false
PROJECT_ID=""

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
    *)
      if [[ -z "$PROJECT_ID" ]]; then
        PROJECT_ID="$1"
      else
        echo -e "${RED}Error: Unknown parameter $1${NC}"
        echo "Usage: ./scrub_project.sh PROJECT_ID [--dry-run] [--no-ask]"
        exit 1
      fi
      shift
      ;;
  esac
done

# Validate project ID
if [[ -z "$PROJECT_ID" ]]; then
  echo -e "${RED}Error: PROJECT_ID is required${NC}"
  echo "Usage: ./scrub_project.sh PROJECT_ID [--dry-run] [--no-ask]"
  exit 1
fi

# Check if project exists
if ! gcloud projects describe "$PROJECT_ID" &>/dev/null; then
  echo -e "${RED}Error: Project $PROJECT_ID does not exist or you don't have access to it${NC}"
  exit 1
fi

# Function to execute or echo command based on dry run flag
execute() {
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

# Print script mode
if [[ "$DRY_RUN" == true ]]; then
  echo -e "${BOLD}Running in DRY RUN mode. No resources will be deleted.${NC}"
else
  echo -e "${BOLD}${RED}WARNING: This will DELETE resources in project: $PROJECT_ID${NC}"
  if ! confirm "Are you sure you want to continue?"; then
    echo "Operation cancelled."
    exit 0
  fi
fi

echo -e "${BOLD}Starting cleanup of resources in project: $PROJECT_ID${NC}"

# 1. GKE Clusters
echo -e "\n${BOLD}Checking for GKE clusters...${NC}"
CLUSTERS=$(gcloud container clusters list --project="$PROJECT_ID" --format="value(name,zone)" 2>/dev/null || echo "")
if [[ -n "$CLUSTERS" ]]; then
  echo "Found GKE clusters:"
  echo "$CLUSTERS" | while read -r NAME ZONE; do
    echo "- $NAME (zone: $ZONE)"
  done

  if confirm "Delete these GKE clusters?"; then
    echo "$CLUSTERS" | while read -r NAME ZONE; do
      execute "gcloud container clusters delete $NAME --zone=$ZONE --quiet --project=$PROJECT_ID"
    done
  fi
else
  echo "No GKE clusters found."
fi

# 2. Cloud SQL Instances
echo -e "\n${BOLD}Checking for Cloud SQL instances...${NC}"
SQL_INSTANCES=$(gcloud sql instances list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null || echo "")
if [[ -n "$SQL_INSTANCES" ]]; then
  echo "Found Cloud SQL instances:"
  echo "$SQL_INSTANCES" | while read -r NAME; do
    echo "- $NAME"
  done

  if confirm "Delete these Cloud SQL instances?"; then
    echo "$SQL_INSTANCES" | while read -r NAME; do
      execute "gcloud sql instances delete $NAME --quiet --project=$PROJECT_ID"
    done
  fi
else
  echo "No Cloud SQL instances found."
fi

# 3. Compute Instances
echo -e "\n${BOLD}Checking for Compute instances...${NC}"
INSTANCES=$(gcloud compute instances list --project="$PROJECT_ID" --format="value(name,zone)" 2>/dev/null || echo "")
if [[ -n "$INSTANCES" ]]; then
  echo "Found Compute instances:"
  echo "$INSTANCES" | while read -r NAME ZONE; do
    echo "- $NAME (zone: $ZONE)"
  done

  if confirm "Delete these Compute instances?"; then
    echo "$INSTANCES" | while read -r NAME ZONE; do
      execute "gcloud compute instances delete $NAME --zone=$ZONE --quiet --project=$PROJECT_ID"
    done
  fi
else
  echo "No Compute instances found."
fi

# 4. Firewall Rules
echo -e "\n${BOLD}Checking for Firewall rules...${NC}"
FIREWALL_RULES=$(gcloud compute firewall-rules list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null || echo "")
if [[ -n "$FIREWALL_RULES" ]]; then
  echo "Found Firewall rules:"
  echo "$FIREWALL_RULES" | while read -r NAME; do
    echo "- $NAME"
  done

  if confirm "Delete these Firewall rules?"; then
    echo "$FIREWALL_RULES" | while read -r NAME; do
      # Skip default firewall rules
      if [[ "$NAME" != "default-allow-"* ]]; then
        execute "gcloud compute firewall-rules delete $NAME --quiet --project=$PROJECT_ID"
      else
        echo -e "${YELLOW}Skipping default firewall rule: $NAME${NC}"
      fi
    done
  fi
else
  echo "No custom Firewall rules found."
fi

# 5. VPC Networks and Subnets
echo -e "\n${BOLD}Checking for VPC networks...${NC}"
NETWORKS=$(gcloud compute networks list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null || echo "")
if [[ -n "$NETWORKS" ]]; then
  echo "Found VPC networks:"
  for NETWORK in $NETWORKS; do
    if [[ "$NETWORK" != "default" ]]; then
      echo "- $NETWORK"

      # List subnets for this network
      SUBNETS=$(gcloud compute networks subnets list --network="$NETWORK" --project="$PROJECT_ID" --format="value(name,region)" 2>/dev/null || echo "")
      if [[ -n "$SUBNETS" ]]; then
        echo "  Subnets:"
        echo "$SUBNETS" | while read -r NAME REGION; do
          echo "  - $NAME (region: $REGION)"
        done
      fi
    fi
  done

  if confirm "Delete these VPC networks and their subnets?"; then
    for NETWORK in $NETWORKS; do
      if [[ "$NETWORK" != "default" ]]; then
        # Delete subnets first
        SUBNETS=$(gcloud compute networks subnets list --network="$NETWORK" --project="$PROJECT_ID" --format="value(name,region)" 2>/dev/null || echo "")
        if [[ -n "$SUBNETS" ]]; then
          echo "$SUBNETS" | while read -r NAME REGION; do
            execute "gcloud compute networks subnets delete $NAME --region=$REGION --quiet --project=$PROJECT_ID"
          done
        fi

        # Then delete the network
        execute "gcloud compute networks delete $NETWORK --quiet --project=$PROJECT_ID"
      else
        echo -e "${YELLOW}Skipping default network${NC}"
      fi
    done
  fi
else
  echo "No custom VPC networks found."
fi

# 6. Cloud Storage Buckets
echo -e "\n${BOLD}Checking for Storage buckets...${NC}"
BUCKETS=$(gsutil ls -p "$PROJECT_ID" 2>/dev/null || echo "")
if [[ -n "$BUCKETS" ]]; then
  echo "Found Storage buckets:"
  echo "$BUCKETS" | while read -r BUCKET; do
    echo "- $BUCKET"
  done

  if confirm "Delete these Storage buckets and all their contents?"; then
    echo "$BUCKETS" | while read -r BUCKET; do
      execute "gsutil -m rm -r $BUCKET"
    done
  fi
else
  echo "No storage buckets found."
fi

# 7. Service Accounts
echo -e "\n${BOLD}Checking for Service accounts...${NC}"
SERVICE_ACCOUNTS=$(gcloud iam service-accounts list --project="$PROJECT_ID" --format="value(email)" 2>/dev/null || echo "")
if [[ -n "$SERVICE_ACCOUNTS" ]]; then
  echo "Found Service accounts:"
  echo "$SERVICE_ACCOUNTS" | grep -v "compute@developer.gserviceaccount.com" | grep -v "cloudbuild@" | while read -r EMAIL; do
    echo "- $EMAIL"
  done

  if confirm "Delete these Service accounts?"; then
    echo "$SERVICE_ACCOUNTS" | grep -v "compute@developer.gserviceaccount.com" | grep -v "cloudbuild@" | while read -r EMAIL; do
      execute "gcloud iam service-accounts delete $EMAIL --quiet --project=$PROJECT_ID"
    done
  fi
else
  echo "No custom Service accounts found."
fi

# 8. Pub/Sub Topics
echo -e "\n${BOLD}Checking for Pub/Sub topics...${NC}"
TOPICS=$(gcloud pubsub topics list --project="$PROJECT_ID" --format="value(name)" 2>/dev/null || echo "")
if [[ -n "$TOPICS" ]]; then
  echo "Found Pub/Sub topics:"
  echo "$TOPICS" | while read -r TOPIC; do
    echo "- $TOPIC"
  done

  if confirm "Delete these Pub/Sub topics?"; then
    echo "$TOPICS" | while read -r TOPIC; do
      execute "gcloud pubsub topics delete $TOPIC --project=$PROJECT_ID"
    done
  fi
else
  echo "No Pub/Sub topics found."
fi

# 9. Load Balancers and Forwarding Rules
echo -e "\n${BOLD}Checking for Forwarding Rules...${NC}"
FORWARDING_RULES=$(gcloud compute forwarding-rules list --project="$PROJECT_ID" --format="value(name,region)" 2>/dev/null || echo "")
if [[ -n "$FORWARDING_RULES" ]]; then
  echo "Found Forwarding Rules:"
  echo "$FORWARDING_RULES" | while read -r NAME REGION; do
    echo "- $NAME (region: $REGION)"
  done

  if confirm "Delete these Forwarding Rules?"; then
    echo "$FORWARDING_RULES" | while read -r NAME REGION; do
      execute "gcloud compute forwarding-rules delete $NAME --region=$REGION --quiet --project=$PROJECT_ID"
    done
  fi
else
  echo "No Forwarding Rules found."
fi

# 10. Custom IAM Roles
echo -e "\n${BOLD}Checking for Custom IAM Roles...${NC}"
CUSTOM_ROLES=$(gcloud iam roles list --project="$PROJECT_ID" --show-deleted --format="value(name)" 2>/dev/null || echo "")
if [[ -n "$CUSTOM_ROLES" ]]; then
  echo "Found Custom IAM Roles:"
  # Filter out soft-deleted roles as we'll handle them separately
  ACTIVE_ROLES=()
  echo "$CUSTOM_ROLES" | while read -r ROLE_PATH; do
    ROLE_NAME=${ROLE_PATH#"projects/$PROJECT_ID/roles/"}
    ROLE_STATE=$(gcloud iam roles describe "$ROLE_NAME" --project="$PROJECT_ID" --format="value(deleted)" 2>/dev/null || echo "")

    if [[ "$ROLE_STATE" != "True" ]]; then
      echo -e "- ${ROLE_NAME}"
      ACTIVE_ROLES+=("$ROLE_PATH")
    fi
  done

  if confirm "Delete these Custom IAM Roles?"; then
    echo "$CUSTOM_ROLES" | while read -r ROLE_PATH; do
      ROLE_NAME=${ROLE_PATH#"projects/$PROJECT_ID/roles/"}

      # Skip the testflightBootstrap role
      if [[ "$ROLE_NAME" == "testflightBootstrap" ]]; then
        echo -e "${YELLOW}Skipping protected role: $ROLE_NAME${NC}"
        continue
      fi

      # First, check if the role is already in a deleted state
      ROLE_STATE=$(gcloud iam roles describe "$ROLE_NAME" --project="$PROJECT_ID" --format="value(deleted)" 2>/dev/null || echo "")

      if [[ "$ROLE_STATE" == "True" ]]; then
        echo -e "${YELLOW}Role ${ROLE_NAME} is already in deleted state. Attempting to undelete and purge...${NC}"
        # Undelete the role first
        execute "gcloud iam roles undelete \"$ROLE_NAME\" --project=\"$PROJECT_ID\""
      fi

      # Delete the role (--force flag is not supported)
      execute "gcloud iam roles delete \"$ROLE_NAME\" --project=\"$PROJECT_ID\""
    done
  fi
else
  echo "No Custom IAM Roles found."
fi

# 11. Soft-Deleted IAM Roles
echo -e "\n${BOLD}Checking for Soft-Deleted IAM Roles...${NC}"
DELETED_ROLES=$(gcloud iam roles list --project="$PROJECT_ID" --show-deleted --format="json" | \
  jq -r '.[] | select(.deleted==true) | .name' 2>/dev/null || echo "")

if [[ -n "$DELETED_ROLES" ]]; then
  echo "Found Soft-Deleted IAM Roles:"
  MATCHING_DELETED_ROLES=()

  while read -r ROLE_PATH; do
    ROLE_NAME=${ROLE_PATH#"projects/$PROJECT_ID/roles/"}

    # Special handling for testflightBootstrap role (case-insensitive)
    if [[ "$ROLE_NAME" == "testflightBootstrap" || "$ROLE_NAME" == "TestflightBootstrap" ]]; then
      echo -e "- ${YELLOW}${ROLE_NAME}${NC} - ${YELLOW}protected role, will be skipped${NC}"
      continue
    fi

    # Check if role matches the prefix filter
    if [[ "$ROLE_NAME" == "$PREFIX_FILTER"* ]]; then
      echo -e "- ${GREEN}${ROLE_NAME}${NC} - ${GREEN}matches prefix, will be recovered and deleted${NC}"
      MATCHING_DELETED_ROLES+=("$ROLE_NAME")
    else
      echo -e "- ${YELLOW}${ROLE_NAME}${NC} - ${YELLOW}doesn't match prefix, will be skipped${NC}"
    fi
  done <<< "$DELETED_ROLES"

  if [[ ${#MATCHING_DELETED_ROLES[@]} -gt 0 ]]; then
    if confirm "Recover and delete these ${#MATCHING_DELETED_ROLES[@]} soft-deleted roles matching prefix '$PREFIX_FILTER'?"; then
      for ROLE_NAME in "${MATCHING_DELETED_ROLES[@]}"; do
        echo -e "Processing soft-deleted role: ${ROLE_NAME}"
        # First undelete the role to recover it
        execute "gcloud iam roles undelete \"$ROLE_NAME\" --project=\"$PROJECT_ID\""
        # Then delete it again to restart the deletion process
        execute "gcloud iam roles delete \"$ROLE_NAME\" --project=\"$PROJECT_ID\""
        echo -e "${YELLOW}Note: Role ${ROLE_NAME} has been soft-deleted. It will be permanently deleted after 7 days.${NC}"
      done
    fi
  else
    echo "No soft-deleted IAM Roles matching prefix '$PREFIX_FILTER' found (excluding protected roles)."
  fi
else
  echo "No soft-deleted IAM roles found."
fi

# 12. Check for any roles that couldn't be fully purged
if [[ "$DRY_RUN" == false ]]; then
  echo -e "\n${BOLD}Checking for any roles that couldn't be fully purged...${NC}"
  REMAINING_ROLES=$(gcloud iam roles list --project="$PROJECT_ID" --show-deleted --format="value(name)" 2>/dev/null || echo "")

  if [[ -n "$REMAINING_ROLES" ]]; then
    echo "Found roles that may still exist (either active or soft-deleted):"
    echo "$REMAINING_ROLES" | while read -r ROLE_PATH; do
      ROLE_NAME=${ROLE_PATH#"projects/$PROJECT_ID/roles/"}
      ROLE_STATE=$(gcloud iam roles describe "$ROLE_NAME" --project="$PROJECT_ID" --format="value(deleted)" 2>/dev/null || echo "")

      if [[ "$ROLE_STATE" == "True" ]]; then
        echo -e "  - ${YELLOW}${ROLE_NAME}${NC} (soft-deleted, will be purged after 7 days)"
      else
        echo -e "  - ${GREEN}${ROLE_NAME}${NC} (active)"
      fi
    done

    echo -e "\n${YELLOW}Note: Soft-deleted roles will be automatically purged after 7 days.${NC}"
    echo "If you need to use the same role name immediately, you'll need to wait for the purge or use a different name."
  else
    echo "No remaining roles found."
  fi
fi

echo -e "\n${BOLD}Project cleanup process completed.${NC}"
if [[ "$DRY_RUN" == true ]]; then
  echo -e "${YELLOW}This was a dry run. No resources were actually deleted.${NC}"
  echo "To actually delete resources, run without the --dry-run flag."
fi
