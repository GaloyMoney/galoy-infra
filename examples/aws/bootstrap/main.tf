
variable "name_prefix" {}
variable "aws_region"  { default = "us-east-1" }

variable "tf_state_bucket_force_destroy" { default = false }
variable "tf_state_bucket_name"          { default = "" }
variable "tf_lock_table_name"            { default = "" }

variable "external_users" {
  type    = list(string)
  default = []
}


module "bootstrap" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/aws?ref=<commit-sha>"
  source = "../../../modules/bootstrap/aws"   
  name_prefix                   = var.name_prefix
  aws_region                    = var.aws_region
  tf_state_bucket_force_destroy = var.tf_state_bucket_force_destroy
  tf_state_bucket_name          = var.tf_state_bucket_name
  tf_lock_table_name            = var.tf_lock_table_name
  external_users                = var.external_users
}


output "inception_role_arn" {
  value = module.bootstrap.inception_role_arn
}

output "tf_state_bucket_name" {
  value = module.bootstrap.tf_state_bucket_name
}

output "tf_lock_table_name" {
  value = module.bootstrap.tf_lock_table_name
}

output "aws_region" {
  value = module.bootstrap.aws_region
}

output "name_prefix" {
  value = var.name_prefix
}
