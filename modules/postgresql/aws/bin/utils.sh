#!/bin/bash

# Common utility functions for PostgreSQL module operations

# Get terraform output with error handling
get_terraform_output() {
    local output_name="$1"
    local output
    output=$(tofu output -json 2>/dev/null | jq -r ".[\"$output_name\"].value" 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$output" ]; then
        echo ""
        return 1
    fi
    echo "$output"
}

# Wait for port to be available
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

# Check required commands
check_requirements() {
    local required_cmds=("aws" "jq" "tofu")
    local missing_cmds=()

    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_cmds+=("$cmd")
        fi
    done

    if [ ${#missing_cmds[@]} -ne 0 ]; then
        echo "Error: Required commands not found: ${missing_cmds[*]}"
        return 1
    fi
    return 0
}

# Get bastion instance ID from inception module
get_bastion_instance_id() {
    local workspace_dir="$1"
    local project_root
    project_root=$(dirname "$(dirname "$workspace_dir")")
    
    pushd "$project_root/inception" >/dev/null || {
        echo "Error: Could not find inception directory"
        return 1
    }
    
    local instance_id
    instance_id=$(tofu output -raw bastion_instance_id 2>/dev/null)
    popd >/dev/null
    
    if [ -z "$instance_id" ]; then
        echo "Error: Could not get bastion instance ID from inception module"
        return 1
    fi
    
    echo "$instance_id"
}

# Setup port forwarding
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

    # Give it a moment to establish
    sleep 5
}

# Cleanup port forwarding
cleanup_port_forwarding() {
    echo "Cleaning up port forwarding..."
    pkill -f "session-m" || true
    sleep 2
} 