
variable "name_prefix" {}
variable "aws_region" { default = "us-east-1" }

variable "cluster_version" { default = "1.30" }
variable "node_default_type" { default = "m6a.large" }
variable "min_default_node_count" { default = 1 }
variable "max_default_node_count" { default = 3 }

variable "eks_cluster_role_arn" {
  description = "ARN of the IAM role for the EKS cluster"
  type        = string
}

variable "eks_nodes_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes"
  type        = string
}

variable "azs_cluster" {
  type    = map(string)
  default = {
    "us-east-1a" = "10.0.20.0/24"
    "us-east-1b" = "10.0.21.0/24"
  }
}

variable "inception_state_backend" {
  description = "Backend configuration for inception state"
  type = object({
    bucket         = string
    key            = string
    region         = string
    dynamodb_table = string
  })
}


data "terraform_remote_state" "inception" {
  backend = "s3"
  config  = {
    bucket         = var.inception_state_backend.bucket
    key            = var.inception_state_backend.key
    region         = var.inception_state_backend.region
    dynamodb_table = var.inception_state_backend.dynamodb_table
  }
}


module "platform" {
  source = "../../../modules/platform/aws"

  name_prefix            = var.name_prefix
  region                 = var.aws_region
  cluster_version        = var.cluster_version
  node_default_type      = var.node_default_type
  min_default_node_count = var.min_default_node_count
  max_default_node_count = var.max_default_node_count

  eks_cluster_role_arn = var.eks_cluster_role_arn
  eks_nodes_role_arn   = var.eks_nodes_role_arn

  azs_cluster = var.azs_cluster
  nat_gateway_ids = data.terraform_remote_state.inception.outputs.nat_gateway_ids

  inception_state_backend = var.inception_state_backend
}


output "cluster_name"        { value = module.platform.cluster_name }
output "cluster_endpoint"    { value = module.platform.cluster_endpoint }
output "cluster_ca_cert" {
  value     = module.platform.cluster_ca_cert
  sensitive = true
}
output "node_security_group" { value = module.platform.node_security_group_id }

output "cluster_subnet_ids"  { value = module.platform.cluster_subnet_ids }

output "irsa_provider_arn"   { value = module.platform.irsa_provider_arn }
