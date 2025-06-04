locals {
  prefix                  = var.name_prefix
  vpc_name                = "${local.prefix}-vpc"
  vpc_cidr                 = var.vpc_cidr                    
  azs                     = var.azs                         
  azs_dmz                 = var.azs_dmz                     
  azs_dmz_keys            = keys(local.azs_dmz)         
  bastion_sg_name         = "${local.prefix}-bastion-sg"
  backups_bucket_name     = "${local.prefix}-backups"
  bastion_instance_type   = var.bastion_instance_type

}

locals {
  name_prefix = var.name_prefix
  region      = var.region
  cluster_name = var.cluster_name != "" ? var.cluster_name : "${var.name_prefix}-cluster"
  bastion_revoke_on_exit = var.bastion_revoke_on_exit
  
  opentofu_version = "1.6.2"
  kubectl_version = var.kubectl_version
  k9s_version     = var.k9s_version
  kratos_version  = var.kratos_version

  inception_admins = [for user in var.users : user.id if user.inception]
  platform_admins  = [for user in var.users : user.id if user.platform]
  bastion_users    = toset(concat([for user in var.users : user.id if user.bastion], local.platform_admins))
}

