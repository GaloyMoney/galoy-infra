
eval "$(jq -r '@sh "rg=\(.resource_group_name ) sa=\(.storage_account)"')"

access_key=$(az storage account keys list --resource-group $rg --account-name $sa --query '[0].value' -o tsv)

jq -n --arg access_key "$access_key" '{"access_key":$access_key}'
