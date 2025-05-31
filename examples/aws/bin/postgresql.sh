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

# Ensure module scripts exist
for script in utils.sh setup.sh destroy.sh; do
    if [ ! -f "$MODULE_BIN/$script" ]; then
        echo "Error: Required module script not found: $script"
        exit 1
    fi
done

# Function to get terraform output
get_terraform_output() {
    local output_name="$1"
    tofu output -json | jq -r ".[\"$output_name\"].value" 2>/dev/null || echo ""
}

# Function to wait for port
wait_for_port() {
    local host="$1"
    local port="$2"
    local max_attempts="${3:-30}"
    local attempt=1

    echo "Waiting for $host:$port to be available..."
    while ! nc -z "$host" "$port" >/dev/null 2>&1; do
        if [ $attempt -ge $max_attempts ]; then
            echo "Timeout waiting for $host:$port"
            return 1
        fi
        echo "Attempt $attempt: Port not available yet, waiting..."
        sleep 2
        ((attempt++))
    done
    echo "Port $port is available!"
    return 0
}

# Function to setup port forwarding
setup_port_forwarding() {
    local endpoint="$1"
    local instance_id="$2"

    # Kill any existing port forwarding sessions
    pkill -f "session-m" || true
    sleep 2

    echo "Setting up port forwarding to $endpoint..."
    aws ssm start-session \
        --target "$instance_id" \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters "{\"host\":[\"$endpoint\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"5433\"]}" &

    # Wait for port forwarding to be established
    if ! wait_for_port "localhost" "5433" 15; then
        echo "Failed to establish port forwarding"
        return 1
    fi
}

# Function to setup initial configuration
setup_config() {
    pushd "$PROJECT_ROOT/bootstrap" >/dev/null
    local tf_state_bucket_name=$(tofu output tf_state_bucket_name | jq -r)
    local name_prefix=$(tofu output name_prefix | jq -r)
    local region=$(tofu output aws_region | jq -r)
    popd >/dev/null

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
create_databases = false
EOF
    popd >/dev/null
}

# Function to cleanup
cleanup() {
    echo "Cleaning up port forwarding..."
    pkill -f "session-m" || true
    sleep 2
}

# Main command handling
cmd="${1:-help}"

case "$cmd" in
    setup)
        # Setup initial configuration
        setup_config
        # Run module setup script
        "$MODULE_BIN/setup.sh" "$POSTGRESQL_DIR"
        ;;
    
    destroy)
        # Run module destroy script
        "$MODULE_BIN/destroy.sh" "$POSTGRESQL_DIR"
        ;;
    
    shell)
        # Setup initial configuration first
        setup_config
        # Run module setup script with database creation
        "$MODULE_BIN/setup.sh" "$POSTGRESQL_DIR" true
        ;;
    
    *)
        echo "Usage: $0 <command>"
        echo "Commands:"
        echo "  setup    - Setup PostgreSQL infrastructure"
        echo "  shell    - Setup and enable databases"
        echo "  destroy  - Destroy PostgreSQL infrastructure"
        exit 1
        ;;
esac 