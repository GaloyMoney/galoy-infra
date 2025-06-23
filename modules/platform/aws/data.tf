data "aws_vpc" "inception" {
  id = local.vpc_id
}

data "aws_subnet" "dmz" {
  for_each = toset(data.terraform_remote_state.inception.outputs.dmz_subnet_ids)
  id       = each.value
}

data "aws_iam_role" "eks_cluster" {
  name = split("/", var.eks_cluster_role_arn)[1]
}

data "aws_iam_role" "eks_nodes" {
  name = split("/", var.eks_nodes_role_arn)[1]
}

data "terraform_remote_state" "inception" {
  backend = "s3"
  config  = var.inception_state_backend
}


