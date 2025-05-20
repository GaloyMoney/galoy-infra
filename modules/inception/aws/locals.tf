locals {
  prefix                  = var.name_prefix
  vpc_name                = "${local.prefix}-vpc"
  vpc_cidr                = "10.0.0.0/16"
  
  # Hardcoded availability zones
  azs                     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Hardcoded subnet CIDRs
  public_subnet_cidrs     = ["10.0.0.0/24"]
  private_subnet_cidrs    = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  
  # Create subnet names based on the hardcoded CIDRs
  public_subnet_names     = [for idx in range(length(local.public_subnet_cidrs)) : "${local.prefix}-public-${idx}"]
  private_subnet_names    = [for idx in range(length(local.private_subnet_cidrs)) : "${local.prefix}-private-${idx}"]
  
  bastion_sg_name         = "${local.prefix}-bastion-sg"
  backups_bucket_name     = "${local.prefix}-backups"
  
  # Hardcoded instance type for bastion
  bastion_instance_type   = "t3.micro"
}