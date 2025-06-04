resource "aws_security_group" "eks_nodes" {
  name        = "${var.name_prefix}-nodes"
  vpc_id      = local.vpc_id
  description = "EKS worker-node security group"

  ingress {
    description = "Allow intra-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow UDP intra-node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  ingress {
    description = "Allow ICMP intra-node communication"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    self        = true
  }

  ingress {
    description = "Allow communication from DMZ subnet"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [for subnet in data.aws_subnet.dmz : subnet.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-nodes-sg"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "cluster_to_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster_api.id
  security_group_id        = aws_security_group.eks_nodes.id
  description             = "Allow cluster API to nodes communication"
}

resource "aws_security_group" "cluster_api" {
  name        = "${var.name_prefix}-cluster-api"
  vpc_id      = local.vpc_id
  description = "EKS cluster API security group"

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-cluster-api-sg"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "nodes_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.cluster_api.id
  description             = "Allow webhook callbacks from nodes"
}

resource "aws_security_group_rule" "dmz_to_cluster" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [for subnet in data.aws_subnet.dmz : subnet.cidr_block]
  security_group_id = aws_security_group.cluster_api.id
  description       = "Allow communication from DMZ subnet"
}
