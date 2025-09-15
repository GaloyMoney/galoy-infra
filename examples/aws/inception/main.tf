variable "name_prefix" {}
variable "aws_region" {default = "us-east-1"}



variable "backups_bucket_force_destroy" {default = false}

variable "eks_oidc_issuer_url" {default= ""}

variable "eks_oidc_thumbprint_list" {default = []}


module "inception" {
  source = "../../../modules/inception/aws"

  name_prefix                  = var.name_prefix
  aws_region                   = var.aws_region
  backups_bucket_force_destroy = var.backups_bucket_force_destroy
  eks_oidc_issuer_url          = var.eks_oidc_issuer_url
  eks_oidc_thumbprint_list     = var.eks_oidc_thumbprint_list
}


output "vpc_id" {
  description = "ID of the VPC created by the inception module"
  value       = module.inception.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.inception.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.inception.private_subnet_ids
}

output "bastion_hostname" {
  description = "Public DNS of the Bastion host"
  value       = module.inception.bastion_hostname
}

output "backups_bucket_name" {
  description = "Name of the backups S3 bucket"
  value       = module.inception.backups_bucket_name
}
