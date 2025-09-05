# galoy-infra Azure examples

This example shows how inputs to the individual modules could look like to bring up a production-ready infrastructure on Microsoft Azure.

It is **not** intended to be used as-is but documents the sequence in which an initial rollout (and teardown) should take place. Every change to one of the `modules` in this repository is tested in our CI pipeline via the code in this example. On a successful run the examples are updated to point to the latest known good version of the modules. This means that when cloning the repository the example *should* work as-is without modification.

## Prerequisites

1. Azure CLI (≥ 2.53.0). Install on Debian/Ubuntu via:
   ```sh
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```
2. Authenticate and select the correct subscription:
   ```sh
   az login
   az account set --subscription <your-subscription-id>
   ```
3. [OpenTofu](https://opentofu.org/) should be available on your `PATH` as the `tofu` binary.

---

## Setup

Clone the repository and change into this folder:

```sh
git clone https://github.com/GaloyMoney/galoy-infra.git
cd galoy-infra/examples/azure
```

All phases are executed through the provided `Makefile`.

---

## Bootstrap phase

The [`bootstrap`](./bootstrap/main.tf) phase is executed against a blank Azure subscription. It creates:

* a resource group that will own the remote state storage account
* a storage account + container to hold Terraform state files
* a service principal that will be used by the other phases

Create a `bootstrap/terraform.tfvars` file containing at least:

```hcl
name_prefix = "<short-name-prefix>"
```

Then run:

```sh
make bootstrap
```

`make bootstrap` will:

1. run `tofu apply` inside `bootstrap`
2. execute `bin/prep-inception.sh` which writes the outputs into `inception/terraform.tfvars` and configures the backend for the inception phase.

---

## Inception phase

The [`inception`](./inception/main.tf) phase provisions the VNet, bastion host, roles and service principals required for the remaining phases.

First, create a `inception/users.auto.tfvars` file to define the users who will have access to the infrastructure:

```hcl
users = [
  {
    id        = "<your-azure-ad-user-id>"
    bastion   = true
    inception = true
    platform  = true
    logs      = true
  }
]
```

**Note:** The `id` should be your Azure AD email address. For external users, use the format `"username_domain.com#EXT#"`.

Execute it via:

```sh
make inception
```

When the run completes you should see outputs similar to:

```text
bastion_public_ip = "<bastion-public-ip>"
vnet_name         = "<vnet-name>"
```

---

## Platform phase (AKS)

The [`platform`](./platform/main.tf) phase brings up the AKS cluster that will run the Galoy stack.

Prepare the backend and variables, then apply:

```sh
bin/prep-platform.sh
make platform
```

Once finished the outputs will include `cluster_name`, `cluster_endpoint` and a base64-encoded kubeconfig.

You can also merge the cluster credentials into your local kubeconfig using the Azure CLI:

```sh
az aks get-credentials --resource-group <name_prefix> --name <cluster_name>
```

---

## Test bastion login

Access to the bastion is managed via Azure AD. Ensure your user is listed in `inception/users.auto.tfvars` with the appropriate permissions.

Generate an SSH configuration and attempt to connect:

```sh
az ssh config -g <name_prefix> -n <name_prefix>-bastion -f sshconfig
ssh -F sshconfig <azure_ad_username>@<name_prefix>-bastion
```

If this succeeds you are ready to continue with the remaining phases, which must be executed *from the bastion*.

---

## Optional phases

### PostgreSQL

Provision a managed PostgreSQL Flexible Server

```sh
bin/prep-postgresql.sh
make postgresql
```

### Smoketest

Deploy roles and service accounts that can be used to run smoketests:

```sh
bin/prep-smoketest.sh
make smoketest
```

---

## Teardown

Destroy the stack in reverse order. Helper targets exist for each phase, e.g.:

```sh
make destroy-smoketest
make destroy-platform
make destroy-inception
make destroy-bootstrap
```

Ensure that state has been removed from the next phase before destroying its backend (the helper targets take care of this where necessary).
