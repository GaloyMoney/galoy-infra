locals {
  prefix                  = var.name_prefix
  vpc_name                = "${local.prefix}-vpc"
  public_subnet_names     = [for idx in range(length(var.public_subnet_cidrs)) : "${local.prefix}-public-${idx}"]
  private_subnet_names    = [for idx in range(length(var.private_subnet_cidrs)) : "${local.prefix}-private-${idx}"]
  bastion_sg_name         = "${local.prefix}-bastion-sg"
  backups_bucket_name     = "${local.prefix}-backups"
}