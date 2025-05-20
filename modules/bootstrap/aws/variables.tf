variable "name_prefix" {
  description = "Project / stage prefix used in resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
}

variable "tf_state_bucket_force_destroy" {
  description = "Allow `terraform destroy` to delete the state bucket"
  type        = bool
}




locals {
  region           = var.aws_region
  bucket_name      = "${var.name_prefix}-tf-state"
  lock_table_name  = "${var.name_prefix}-tf-lock"
  force_destroy    = var.tf_state_bucket_force_destroy
  inception_role   = "${var.name_prefix}-inception-tf"
  bootstrap_policy = "${var.name_prefix}-bootstrap"
}
