#!/bin/bash

set -eu

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Source utility functions
source "$SCRIPT_DIR/utils.sh"

# Check requirements
check_requirements || exit 1

# Function to setup PostgreSQL
setup_postgresql() {
    local workspace_dir="$1"
    local create_databases="${2:-false}"

    cd "$workspace_dir"

    # Initialize Terraform
    tofu init || {
        echo "Error: Failed to initialize Terraform"
        return 1
    }

    # Create or update terraform.tfvars
    if [ -f "terraform.tfvars" ]; then
        # Update create_databases value
        sed -i '' "s/create_databases = .*/create_databases = $create_databases/" terraform.tfvars
    else
        echo "Error: terraform.tfvars not found"
        return 1
    fi

    # Get bastion instance ID first
    local instance_id
    instance_id=$(get_bastion_instance_id "$workspace_dir") || {
        echo "Error: Failed to get bastion instance ID"
        return 1
    }

    # Get the endpoint from existing state if it exists
    local endpoint
    endpoint=$(tofu output -raw postgresql_endpoint 2>/dev/null || echo "")

    # If we have an endpoint, set up port forwarding before apply
    if [ -n "$endpoint" ]; then
        echo "Setting up port forwarding to existing endpoint..."
        setup_port_forwarding "$endpoint" "$instance_id"
    fi

    # Apply Terraform configuration
    if ! tofu apply -auto-approve; then
        echo "Error: Failed to apply Terraform configuration"
        cleanup_port_forwarding
        return 1
    fi

    # Get the final endpoint and setup port forwarding if needed
    endpoint=$(tofu output -raw postgresql_endpoint)
    if [ -z "$endpoint" ]; then
        echo "Error: Failed to get PostgreSQL endpoint"
        cleanup_port_forwarding
        return 1
    fi

    # If this is a new endpoint, setup port forwarding
    if [ -n "$endpoint" ]; then
        echo "Setting up port forwarding to new endpoint..."
        setup_port_forwarding "$endpoint" "$instance_id"
    fi

    echo "PostgreSQL setup completed successfully"
    echo "Connection details:"
    echo "  Host: localhost"
    echo "  Port: 5433"
    echo "  Username: $(tofu output -raw postgresql_username)"
    echo "  Database: postgres"
    return 0
}

# Main
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <workspace_dir> [create_databases]"
    exit 1
fi

workspace_dir="$1"
create_databases="${2:-false}"

setup_postgresql "$workspace_dir" "$create_databases"
trap cleanup_port_forwarding EXIT 