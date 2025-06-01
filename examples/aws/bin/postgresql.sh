#!/bin/bash

set -eu

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
POSTGRESQL_DIR="$PROJECT_ROOT/postgresql"
MODULE_BIN="$PROJECT_ROOT/../../modules/postgresql/aws/bin"

# Check required commands
for cmd in aws jq tofu psql nc; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is required but not installed."
        exit 1
    fi
done

# Function to setup initial configuration
setup_config() {
    pushd "$PROJECT_ROOT/bootstrap" >/dev/null
    local tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
    local name_prefix=$(tofu output name_prefix | jq -r)
    local region=$(tofu output aws_region | jq -r)
    popd >/dev/null

    mkdir -p "$POSTGRESQL_DIR"
    pushd "$POSTGRESQL_DIR" >/dev/null
    
    # Create backend configuration
    cat <<EOF > terraform.tf
terraform {
  backend "s3" {
    bucket = "${tf_state_bucket_name}"
    key    = "${name_prefix}/postgresql/terraform.tfstate"
    region = "${region}"
  }
}
EOF

# Create variables configuration
cat <<EOF > terraform.tfvars
name_prefix = "${name_prefix}"
region = "${region}"
create_databases = true
EOF
    popd >/dev/null
}

# Main command handling
cmd="${1:-help}"

case "$cmd" in
    shell)
        # Setup initial configuration
        setup_config
        
        # Run module setup script
        "$MODULE_BIN/setup.sh" "$POSTGRESQL_DIR" true
        ;;
    
    destroy)
        # Run module destroy script
        "$MODULE_BIN/destroy.sh" "$POSTGRESQL_DIR"
        ;;
    
    *)
        echo "Usage: $0 <command>"
        echo "Commands:"
        echo "  shell    - Setup PostgreSQL and open shell"
        echo "  destroy  - Destroy PostgreSQL infrastructure"
        exit 1
        ;;
esac 