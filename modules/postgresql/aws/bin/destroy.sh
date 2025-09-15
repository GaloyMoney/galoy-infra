#!/bin/bash

set -eu

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODULE_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

source "$SCRIPT_DIR/utils.sh"


destroy_postgresql() {
    local workspace_dir="$1"
    cd "$workspace_dir"

    cleanup_port_forwarding

    if tofu state list 2>/dev/null | grep -q "module.postgresql.module.database"; then
        echo "Removing database resources from state..."
        tofu state rm module.postgresql.module.database || true
    fi

    local max_retries=3
    local retry_count=0

    while [ $retry_count -lt $max_retries ]; do
        if tofu destroy -auto-approve; then
            echo "PostgreSQL resources destroyed successfully"
            return 0
        fi
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            echo "Retry $retry_count of $max_retries..."
            sleep 5
        fi
    done

    echo "Error: Failed to destroy all resources after $max_retries attempts"
    return 1
}

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <workspace_dir>"
    exit 1
fi

workspace_dir="$1"
destroy_postgresql "$workspace_dir" 