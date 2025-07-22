# blink-infra gcp examples

This example shows how inputs to the individual modules could look like to bring up a production ready infrastructure.

It is not intended to be used as is but does document the sequence in which an initial rollout (+ teardown) should take place.
Every change to one of the (`modules`)[../../modules] in this repository is tested in our CI pipeline via the code in this example.
On a successfull run the examples are updated to point to the latest known good version of the modules.
This means that when cloning the repository the example _should_ work as is without modification.

## Setup

To execute this example end-to-end first you must clone the repository and cd into this folder:
```
$ git clone https://github.com/blinkbitcoin/blink-infra.git
$ cd blink-infra/examples/gcp
```

## Bootstrap phase

The [`bootstrap`](./bootstrap/main.tf) phase is intended to be executed against a blank GCP project.
It will create the `inception` service account + GCS bucket to store the terraform state files for the other phases.

Some variables must be set first:
```
$ cat <<EOF > bootstrap/terraform.tfvars
name_prefix                   = "<short-name-prefix>"
gcp_project                   = "<your-gcp-project>"
EOF
$ cat <<EOF > inception/users.auto.tfvars
users = [
  {
    id        = "user:<your-user-email"
    bastion   = true
    inception = true
    platform  = true
    logs      = true
  }
]
EOF
$ make bootstrap
```

Executing `make bootstrap` will execute `tofu apply` in the `bootstrap` folder and also import the relevant resources into the `inception` phase - which will subsequently own the lifecycle of those resources.

## Inception phase

Once bootstrap has been executed the [`inception`](./inception/main.tf) phase can provision the VPC network, bastion, roles and service accounts needed to install the complete blink stack.
Execute it via:
```
$ make inception
```

Once complete you should see outputs that includes the `bastion_name` and `bastion_zone`
```
bastion_name = "<bastion-name>"
bastion_zone = "<bastion-zone>"
```

## Platform phase

The [`platform`](./platform/main.tf) phase in this example will bring up the actual kubernetes platform. Once `inception` is complete you can execute:
```
bin/prep-platform.sh
make platform
```
The result should be (among other things) a k8s cluster running in your gcp project.

## Test bastion login

Since the next phase must be executed from the bastion let's first make sure you are able to ssh there.
Access to the bastion is enabled via [OsLogin](https://cloud.google.com/compute/docs/oslogin) with 2-factor-authentication activated.
That means in order to ssh to the bastion you must first upload your public key via the gcloud cli:
```
gcloud compute os-login ssh-keys add --key-file=~/.ssh/id_rsa.pub
```
and activate a 2FA method in your google account.

Your bastion username is your email address with `_` underscores instead of `.` and `@`:
```
export BASTION_USER="$(echo <your-email> | sed 's/[.@]/_/g')"
```

See if you can ssh via:
```
$ gcloud compute ssh ${bastion_name} --zone=${bastion_zone} --project=${gcp_project}
<select 2fa method>
$ <bastion-user>@<bastion-name>
```
