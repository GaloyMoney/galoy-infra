#!/bin/bash

# Function to prompt for input with validation
get_input() {
    local prompt="$1"
    local var_name="$2"
    local is_password="$3"
    local value

    while true; do
        if [[ "$is_password" == "true" ]]; then
            read -s -p "$prompt: " value
            echo  # Add a newline after password input
        else
            read -p "$prompt: " value
        fi
        if [[ -n "$value" ]]; then
            eval "$var_name='$value'"
            break
        else
            echo "Error: Input cannot be empty. Please try again."
        fi
    done
}

# Get source PostgreSQL instance details
get_input "Enter the source PostgreSQL instance IP" source_ip
get_input "Enter the PostgreSQL user" pg_user
get_input "Enter the PostgreSQL password" pg_password "true"

# Set the default port
source_port=5432

# Set PostgreSQL connection options
PG_OPTS="-h $source_ip -p $source_port -U $pg_user"

# Set PGPASSWORD environment variable
export PGPASSWORD="$pg_password"

# Excluded databases
EXCLUDED_DBS="alloydbadmin|cloudsqladmin|rdsadmin"

# Excluded roles and text to remove
EXCLUDED_ROLES="cloudsqladmin|cloudsqlagent|cloudsqliamserviceaccount|cloudsqliamuser|cloudsqlimportexport|cloudsqlreplica|cloudsqlsuperuser"

# Dump and filter PostgreSQL schema
pg_dumpall $PG_OPTS \
    --exclude-database="$EXCLUDED_DBS" \
    --schema-only \
    --no-role-passwords \
    2>/dev/null | \
sed -E "/$EXCLUDED_ROLES/d; s/NOSUPERUSER//g" | \
grep -E '^(GRANT|REVOKE|\\connect|ALTER.*OWNER.*|CREATE ROLE|ALTER ROLE)'

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Schema dump and filtering completed successfully."
else
    echo "Error: Failed to dump and filter the schema. Please check your connection details and permissions."
fi

# Clear the PGPASSWORD environment variable
unset PGPASSWORD