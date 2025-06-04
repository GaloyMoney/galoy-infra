#!/bin/bash

set -eu

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

source "$SCRIPT_DIR/utils.sh"

setup_postgresql() {
    local workspace_dir="$1"
    local create_databases="${2:-false}"

    cd "$workspace_dir"

    tofu init || {
        echo "Error: Failed to initialize Terraform"
        return 1
    }

    if [ -f "terraform.tfvars" ]; then
        sed -i '' "s/create_databases = .*/create_databases = false/" terraform.tfvars
    else
        echo "Error: terraform.tfvars not found"
        return 1
    fi

    if ! tofu apply -auto-approve -target=module.postgresql.aws_db_instance.instance; then
        echo "Error: Failed to apply Terraform configuration"
        return 1
    fi

    local endpoint
    endpoint=$(tofu output -raw postgresql_endpoint)
    if [ -z "$endpoint" ]; then
        echo "Error: Failed to get PostgreSQL endpoint"
        return 1
    fi

    local instance_id
    instance_id=$(get_bastion_instance_id) || {
        echo "Error: Failed to get bastion instance ID"
        return 1
    }

    echo "Setting up port forwarding to $endpoint..."
    if ! setup_port_forwarding "$endpoint" "$instance_id"; then
        echo "Error: Failed to setup port forwarding"
        cleanup_port_forwarding
        return 1
    fi

    echo "Waiting for port forwarding to be established..."
    if ! wait_for_port "localhost" "5433" 30; then
        echo "Error: Port forwarding not established"
        cleanup_port_forwarding
        return 1
    fi

    if [ "$create_databases" = "true" ]; then
        sed -i '' "s/create_databases = .*/create_databases = true/" terraform.tfvars
    fi

    if ! tofu apply -auto-approve; then
        echo "Error: Failed to apply Terraform configuration"
        return 1
    fi

    echo "PostgreSQL setup completed successfully"
    echo "Connection details:"
    echo "  Host: localhost"
    echo "  Port: 5433"
    echo "  Username: $(tofu output -raw postgresql_username)"
    echo "  Database: postgres"
    return 0
}

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <workspace_dir> [create_databases]"
    exit 1
fi

workspace_dir="$1"
create_databases="${2:-false}"

setup_postgresql "$workspace_dir" "$create_databases"
trap cleanup_port_forwarding EXIT 
