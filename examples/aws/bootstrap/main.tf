
variable "name_prefix" {}
variable "organization_id" {
  description = "AWS Organization ID to attach policies (optional)"
  default     = ""
}
variable "external_users" {
  description = "List of external AWS account IDs for SSM access"
  type        = list(string)
  default     = []
}
variable "tf_state_bucket_name" {
  description = "S3 bucket name for Terraform state (auto-generated if empty)"
  default     = ""
}
variable "tf_state_bucket_force_destroy" {
  description = "Allow destroying non-empty state bucket"
  default     = false
}
variable "enable_services" {
  description = "Whether to register AWS services with AWS Organizations"
  default     = true
}

module "bootstrap" {
  source = "../../../modules/bootstrap/aws"

  name_prefix                  = var.name_prefix
  organization_id              = var.organization_id
  external_users               = var.external_users
  tf_state_bucket_name         = var.tf_state_bucket_name
  tf_state_bucket_force_destroy = var.tf_state_bucket_force_destroy
  enable_services              = var.enable_services
}

output "inception_user_name" {
  description = "The IAM username created for the inception bootstrap"
  value       = module.bootstrap.inception_user_name
}

output "inception_user_arn" {
  description = "The ARN of the inception IAM user"
  value       = module.bootstrap.inception_user_arn
}

output "bootstrap_policy_arn" {
  description = "The ARN of the custom bootstrap policy"
  value       = module.bootstrap.bootstrap_policy_arn
}

output "tf_state_bucket_name" {
  description = "S3 bucket name used for Terraform state"
  value       = module.bootstrap.tf_state_bucket_name
}

output "tf_state_bucket_arn" {
  description = "ARN of the S3 bucket holding Terraform state"
  value       = module.bootstrap.tf_state_bucket_arn
}

output "external_users_policy_id" {
  description = "Organizations policy ID for external-user access (empty if none)"
  value       = module.bootstrap.external_users_policy_id
}

output "enabled_services" {
  description = "List of AWS service principals registered"
  value       = module.bootstrap.enabled_services
}
