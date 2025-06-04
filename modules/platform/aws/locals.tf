locals {
  name_prefix  = var.name_prefix
  cluster_name = "${var.name_prefix}-cluster"
  pods_cidr    = "192.168.0.0/18"
  svc_cidr     = "192.168.64.0/18"
}

locals {
  vpc_id          = data.terraform_remote_state.inception.outputs.vpc_id
  nat_gateway_ids = data.terraform_remote_state.inception.outputs.nat_gateway_ids
  dmz_subnet_ids  = data.terraform_remote_state.inception.outputs.dmz_subnet_ids
}

