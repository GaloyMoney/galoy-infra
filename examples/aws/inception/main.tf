variable "name_prefix" {}
variable "aws_region" {}

variable "azs" {
  description = "List of Availability Zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs allowed to access the Bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "bastion_instance_type" {
  description = "EC2 instance type for the Bastion host"
  type        = string
  default     = "t3.micro"
}

variable "backups_bucket_force_destroy" {
  description = "Allow destroying the backups bucket"
  type        = bool
  default     = false
}

variable "eks_oidc_issuer_url" {
  description = "URL of the EKS OIDC issuer (leave empty if not using IRSA)"
  type        = string
  default     = ""
}

variable "eks_oidc_thumbprint_list" {
  description = "Thumbprint list for the EKS OIDC provider (leave empty if not using IRSA)"
  type        = list(string)
  default     = []
}

module "inception" {
  source = "../../../modules/inception/aws"

  name_prefix                  = var.name_prefix
  aws_region                   = var.aws_region
  azs                          = var.azs
  public_subnet_cidrs          = var.public_subnet_cidrs
  private_subnet_cidrs         = var.private_subnet_cidrs
  allowed_ingress_cidrs        = var.allowed_ingress_cidrs
  bastion_instance_type        = var.bastion_instance_type
  backups_bucket_force_destroy = var.backups_bucket_force_destroy

  eks_oidc_issuer_url      = var.eks_oidc_issuer_url
  eks_oidc_thumbprint_list = var.eks_oidc_thumbprint_list
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
