data "aws_vpc" "inception" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  ids = var.private_subnet_ids
}

data "aws_subnet" "public_dmz" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}

data "aws_iam_role" "eks_cluster" {
  arn = var.eks_cluster_role_arn
}

data "aws_iam_role" "eks_nodes" {
  arn = var.eks_nodes_role_arn
}
