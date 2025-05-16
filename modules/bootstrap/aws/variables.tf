variable "name_prefix" {
  description = "Prefix to use for all AWS resources"
  type        = string
}

variable "organization_id" {
  description = "AWS Organization ID to target (required for external-users policy)"
  type        = string
  default     = ""
}

variable "external_users" {
  description = "List of external AWS account IDs to grant limited SSM access"
  type        = list(string)
  default     = []
}

variable "tf_state_bucket_force_destroy" {
  description = "Whether to force-destroy the S3 bucket holding Terraform state"
  type        = bool
  default     = false
}

variable "tf_state_bucket_name" {
  description = "Name to give the S3 bucket for Terraform state (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "enable_services" {
  description = "Whether to register AWS service principals in the Organization"
  type        = bool
  default     = true
}

locals {
  organization_id               = var.organization_id
  external_users                = var.external_users
  name_prefix                   = var.name_prefix
  tf_state_bucket_force_destroy = var.tf_state_bucket_force_destroy
  tf_state_bucket_name = var.tf_state_bucket_name != "" ? var.tf_state_bucket_name : "${var.name_prefix}-${data.aws_caller_identity.current.account_id}-tf-state"
}
