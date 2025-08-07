variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "backups_bucket_force_destroy" {
  description = "Allow destroy backups bucket"
  type        = bool
  default     = false
}
variable "eks_oidc_issuer_url" {
  description = "OIDC issuer URL for EKS (leave empty to skip IRSA)"
  type        = string
  default     = ""
}

variable "eks_oidc_thumbprint_list" {
  description = "OIDC issuer thumbprint list (leave empty to skip IRSA)"
  type        = list(string)
  default     = []
}