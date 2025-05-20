variable "name_prefix" {}
variable "aws_region"  { default = "us-east-1" }

variable "tf_state_bucket_force_destroy" { default = true }

module "bootstrap" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/aws?ref=<commit-sha>"
  source = "../../../modules/bootstrap/aws"   
  name_prefix                   = var.name_prefix
  aws_region                    = var.aws_region
  tf_state_bucket_force_destroy = var.tf_state_bucket_force_destroy
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
