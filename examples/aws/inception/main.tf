variable "name_prefix"            {}
variable "region"             { default = "us-east-1" }
variable "backups_bucket_force_destroy" { default = false }

variable "vpc_cidr" { default = "10.0.0.0/16" }

variable "azs" {
  type    = map(string)
  default = {
    "us-east-1a" = "10.0.0.0/24"
    "us-east-1b" = "10.0.1.0/24"
  }
}

variable "azs_dmz" {
  type    = map(string)
  default = {
    "us-east-1a" = "10.0.10.0/24"
    "us-east-1b" = "10.0.11.0/24"
  }
}


module "inception" {
  source = "../../../modules/inception/aws"


  name_prefix                  = var.name_prefix
  region                       = var.region
  backups_bucket_force_destroy = var.backups_bucket_force_destroy

  vpc_cidr = var.vpc_cidr
  azs      = var.azs
  azs_dmz  = var.azs_dmz
}


output "vpc_id"            { value = module.inception.vpc_id }
output "public_subnet_ids" { value = module.inception.public_subnet_ids }

output "dmz_subnet_ids"    { value = module.inception.dmz_subnet_ids }
output "nat_gateway_ids"   { value = module.inception.nat_gateway_ids }

output "bastion_hostname"       { value = module.inception.bastion_hostname }
output "bastion_security_group" { value = module.inception.bastion_security_group_id }
output "backups_bucket_name"    { value = module.inception.backups_bucket_name }

output "eks_cluster_role_arn" { value = module.inception.eks_cluster_role_arn }
output "eks_nodes_role_arn"   { value = module.inception.eks_nodes_role_arn }
