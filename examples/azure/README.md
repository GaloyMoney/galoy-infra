export ARM_CLIENT_ID=$(cd inception && terraform output client_id | jq -r)
export ARM_CLIENT_SECRET=$(cd inception && terraform output client_secret | jq -r)
export ARM_TENANT_ID=$(cd inception && terraform output tenant_id | jq -r)
export ARM_SUBSCRIPTION_ID=$(cd inception && terraform output subscription_id | jq -r)
export ARM_ACCESS_KEY=$(cd inception && terraform output access_key | jq -r)

Possible ways to connect with cluster :
[connectedk8s](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/quickstart-connect-cluster?tabs=azure-cli)
