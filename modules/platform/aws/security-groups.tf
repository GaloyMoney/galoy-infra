resource "aws_security_group" "nodes" {
  name        = "${local.cluster_name}-nodes-sg"
  description = "Intra‑node, control‑plane, and bastion access"
  vpc_id      = data.aws_vpc.inception.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.inception.cidr_block, local.pods_cidr, local.svc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.inception.cidr_block, local.pods_cidr, local.svc_cidr]
  }
}

resource "aws_security_group_rule" "public_to_nodes" {
  for_each             = data.aws_subnet.public_dmz
  type                 = "ingress"
  from_port            = 0
  to_port              = 0
  protocol             = "-1"
  security_group_id    = aws_security_group.nodes.id
  cidr_blocks          = [each.value.cidr_block]
  description          = "DMZ/public subnet ingress"
}

resource "aws_security_group_rule" "bastion_to_api" {
  type                         = "ingress"
  from_port                    = 443
  to_port                      = 443
  protocol                     = "tcp"
  security_group_id            = aws_security_group.nodes.id
  source_security_group_id     = var.bastion_sg_id
  description                  = "Allow bastion → private EKS API"
}