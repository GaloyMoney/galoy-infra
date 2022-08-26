```sh
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>
```
