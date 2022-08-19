az storage account keys list --resource-group $1 --account-name $2 --query '[0].value' -o tsv
