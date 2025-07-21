resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for ${local.cluster_name} secret encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_eks_cluster" "primary" {
  name     = "${var.name_prefix}-cluster"
  role_arn = var.eks_cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids     = [aws_security_group.cluster_api.id]
    subnet_ids             = [for subnet in aws_subnet.cluster_private : subnet.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = local.svc_cidr
    ip_family         = "ipv4"
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

  tags = { 
    Name = local.cluster_name
    Environment = var.name_prefix
  }

  depends_on = [
    aws_security_group_rule.cluster_to_nodes,
    aws_security_group_rule.nodes_to_cluster,
    aws_security_group_rule.dmz_to_cluster
  ]
}

resource "aws_launch_template" "eks_nodes" {
  name = "${local.name_prefix}-eks-nodes"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 100
      volume_type          = "gp3"
      delete_on_termination = true
      encrypted            = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.eks_nodes.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.cluster_name}-node"
    }
  }

  user_data = base64encode(<<-EOF
    [settings.kubernetes]
    api-server = "${aws_eks_cluster.primary.endpoint}"
    cluster-certificate = "${aws_eks_cluster.primary.certificate_authority[0].data}"
    cluster-name = "${local.cluster_name}"
    EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.primary.name
  node_group_name = "${var.name_prefix}-default"
  node_role_arn   = var.eks_nodes_role_arn
  subnet_ids      = [for subnet in aws_subnet.cluster_private : subnet.id]
  
  scaling_config {
    desired_size = var.min_default_node_count
    max_size     = var.max_default_node_count
    min_size     = var.min_default_node_count
  }

  ami_type       = "BOTTLEROCKET_x86_64"
  instance_types = [var.node_default_type]

  update_config {
    max_unavailable_percentage = 33
  }

  launch_template {
    name    = aws_launch_template.eks_nodes.name
    version = aws_launch_template.eks_nodes.latest_version
  }

  capacity_type = "ON_DEMAND"

  labels = {
    cluster_name = local.cluster_name
    node_pool    = "${var.name_prefix}-default-nodes"
  }

  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NO_SCHEDULE"
  }

  tags = { 
    Name = "${local.cluster_name}-nodes"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes       = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_route_table_association.cluster_assoc
  ]
}


