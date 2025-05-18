# File: iam.tf

locals {
  default_tags = {
    Project = local.prefix
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${local.prefix}-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${local.prefix}-bastion-profile"
  role = aws_iam_role.bastion.name
  tags = local.default_tags
}

variable "eks_oidc_issuer_url" {
  description = "OIDC issuer URL for EKS (leave empty to skip IRSA)"
  type        = string
  default     = ""
}

variable "eks_oidc_thumbprint_list" {
  description = "OIDC issuer thumbprint list (leave empty to skip IRSA)"
  type        = list(string)
  default     = []
}

resource "aws_iam_openid_connect_provider" "eks" {
  count           = var.eks_oidc_issuer_url != "" ? 1 : 0
  url             = var.eks_oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.eks_oidc_thumbprint_list
  tags            = local.default_tags
}

resource "aws_iam_role" "alb_controller" {
  count = var.eks_oidc_issuer_url != "" ? 1 : 0
  name  = "${local.prefix}-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Federated = aws_iam_openid_connect_provider.eks[0].arn },
      Action    = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(var.eks_oidc_issuer_url, "https://", "")} :sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
  tags = local.default_tags
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  count      = var.eks_oidc_issuer_url != "" ? 1 : 0
  role       = aws_iam_role.alb_controller[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}
