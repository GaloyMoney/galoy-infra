variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket = "${var.name_prefix}-tf-state"
    key    = "${var.name_prefix}/bootstrap/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "inception" {
  backend = "s3"
  config = {
    bucket = "${var.name_prefix}-tf-state"
    key    = "${var.name_prefix}/inception/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "platform" {
  backend = "s3"
  config = {
    bucket = "${var.name_prefix}-tf-state"
    key    = "${var.name_prefix}/platform/terraform.tfstate"
    region = var.region
  }
}

output "bootstrap_outputs" {
  value = {
    inception_role_arn    = data.terraform_remote_state.bootstrap.outputs.inception_role_arn
    tf_state_bucket_name  = data.terraform_remote_state.bootstrap.outputs.tf_state_bucket_name
    tf_lock_table_name    = data.terraform_remote_state.bootstrap.outputs.tf_lock_table_name
  }
}

output "inception_outputs" {
  value = {
    vpc_id                    = data.terraform_remote_state.inception.outputs.vpc_id
    bastion_hostname          = data.terraform_remote_state.inception.outputs.bastion_hostname
    backups_bucket_name       = data.terraform_remote_state.inception.outputs.backups_bucket_name
    eks_cluster_role_arn      = data.terraform_remote_state.inception.outputs.eks_cluster_role_arn
    eks_nodes_role_arn        = data.terraform_remote_state.inception.outputs.eks_nodes_role_arn
  }
}

output "platform_outputs" {
  value = {
    cluster_name      = data.terraform_remote_state.platform.outputs.cluster_name
    cluster_endpoint  = data.terraform_remote_state.platform.outputs.cluster_endpoint
    irsa_provider_arn = data.terraform_remote_state.platform.outputs.irsa_provider_arn
  }
} 