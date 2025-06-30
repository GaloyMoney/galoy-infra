# blink-infra

This repository contains [terraform](https://www.terraform.io) definitions to bring up a robust infrastructure implementation suitable for running the [blink](https://github.com/blinkbitcoin/blink) stack.
It is production ready by default.

The infrastructure is organized into 4 modules that must be executed in sequence.
They can be executed against a completly blank google cloud project with `owner` access.
The final state is a regional gke cluster running on a private network with a bastion host deployed for connectivity.

## [modules](./modules)

- `bootstrap` - Enables required APIs and provisions the initial "inception" service account as well as the GCS bucket to store all terraform state required in all other phases. This step should be executed 1 time only and not automated.
- `inception` - Provisions all security sensitive resourced like the vpc network, bastion, roles, service accounts etc.
- `platform` - Provisions the gke cluster itself. The version is defined the the `kube_version` variable in the [variables.tf](./modules/platform/gcp/variables.tf) file and needs to be a [supported version by GKE.](https://cloud.google.com/kubernetes-engine/docs/release-notes)

The `bootstrap`, `inception` and `platform` modules currently only support GCP.
In the future additional versions of the first 3 modules will be developped to support other IaaSes.

The structure of the modules is intended to support continous delivery.
After initial deploy moving from 1 version to the next should always be smooth and automatable - albeit the sequence of the rollout should remain unchanged.

## Usage

The initial deploy - while it is automatable - does have a few caveats.
A complete walkthrough of a rollout is documented in the [examples/gcp](./examples/gcp) folder.
