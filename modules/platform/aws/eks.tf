resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for ${local.cluster_name} secret encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_eks_cluster" "primary" {
  name     = local.cluster_name
  version  = var.cluster_version
  role_arn = data.aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = data.aws_subnets.private.ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [aws_security_group.nodes.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = local.svc_cidr
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }

  enabled_cluster_log_types = ["api", "audit", "controllerManager", "scheduler"]
  tags = { Name = local.cluster_name }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.primary.name
  node_group_name = "${local.name_prefix}-default-node-group"
  node_role_arn   = data.aws_iam_role.eks_nodes.arn
  subnet_ids      = data.aws_subnets.private.ids

  scaling_config {
    desired_size = var.min_default_node_count
    min_size     = var.min_default_node_count
    max_size     = var.max_default_node_count
  }

  ami_type       = "BOTTLEROCKET_x86_64"
  instance_types = [var.node_default_type]

  update_config {
    max_unavailable = 1
  }
  capacity_type = "ON_DEMAND"
  tags = { Name = "${local.cluster_name}-nodes" }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_openid_connect_provider" "cluster" {
  url             = aws_eks_cluster.primary.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
}

data "tls_certificate" "oidc" {
  url = aws_eks_cluster.primary.identity[0].oidc[0].issuer
}
