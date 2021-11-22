# 1-Tap Infrastructure Provisioning

This folder contains single executable scripts to provision the entire infrastructure as-is.
Currently, since we are on Google Cloud Platform, there is only the one script for deploying to the same, more will be added as support grow.

## Requirements

Before running this script, you should have the following software installed:
1. [GitHub CLI](https://cli.github.com/)
2. [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. [Terraform](https://www.terraform.io/)

- You should have a GMail or Google Workspace account with 2FA enabled.
- You should already have an SSH Key setup for you whose public key lives in `~/.ssh/id_rsa.pub`.

## Running

1. Once you run the script, it will create a temporary directory inside of which it's going to clone this repository.
2. Then, it's going to prompt you to login to gcloud.
3. While testing out, it has logic to create a random project for you but if you have a proper project set up on GCP, you can give your GCP Project ID during execution.
4. After that, you will be prompted to enter a name perfix which would ideally be something related to the environment you're deploying for, like staging or production. It is used to name every infrastructure component.
5. You should also enter your email address in proper format: `email@example.com`. 
6. It is crucuial that the email you enter here is a `gmail.com` email address or is associated with a GSuite/Google Workspace account. It is because for the 2FA to work on the bastion, Google services would need to confirm your identity.

Finally, sit back and relax!
The entire setup takes about 18-20 minutes to complete. 
At the near end of the setup, you'll be prompted twice for your 2FA bastion SSH approvals. 
Those approvals will copy the infrastructure files onto the bastion and bring up the platform.

The script ends with the bastion's IP address for you to quickly ssh into.
The bastion is set up so that it can talk with GKE.
Save them for safekeeping or add them to `~/.ssh/config` for later use.
