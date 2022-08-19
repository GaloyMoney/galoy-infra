export ARM_CLIENT_ID=$(cd inception && terraform output client_id | jq -r)
export ARM_CLIENT_SECRET=$(cd inception && terraform output client_secret | jq -r)
export ARM_TENANT_ID=$(cd inception && terraform output tenant_id | jq -r)
