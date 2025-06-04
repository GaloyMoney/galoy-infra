#!/bin/bash

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

get_bastion_instance_id() {
    local tfvars_file="$workspace_dir/terraform.tfvars"
    if [ ! -f "$tfvars_file" ]; then
        echo "Error: terraform.tfvars not found in $workspace_dir" >&2
        return 1
    fi


    local instance_id
    instance_id=$(grep bastion_instance_id "$tfvars_file" | cut -d'"' -f2)

    if [ -z "$instance_id" ]; then
        echo "Error: Could not parse bastion_instance_id from terraform.tfvars" >&2
        return 1
    fi

    echo "$instance_id"
}

setup_port_forwarding() {
    local endpoint="$1"
    local instance_id="$2"

    local hostname
    hostname=$(echo "$endpoint" | cut -d':' -f1)

    local ip_address
    ip_address=$(dig +short "$hostname")
    
    if [ -z "$ip_address" ]; then
        echo "Error: Could not resolve $hostname to IP address"
        return 1
    fi

    pkill -f "session-m" || true
    sleep 2

    echo "Setting up port forwarding to $ip_address..."
    aws ssm start-session \
        --target "$instance_id" \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters "{\"host\":[\"$ip_address\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"5433\"]}" &

    local attempts=0
    while ! nc -z localhost 5433 >/dev/null 2>&1; do
        ((attempts++))
        if [ $attempts -ge 15 ]; then
            echo "Error: Failed to establish port forwarding after 30 seconds"
            return 1
        fi
        echo "Waiting for port forwarding to be established..."
        sleep 2
    done

    echo "Port forwarding established successfully"
    return 0
}

cleanup_port_forwarding() {
    echo "Cleaning up port forwarding..."
    pkill -f "session-m" || true
    sleep 2
} 
