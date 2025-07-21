resource "aws_security_group" "bastion" {
  name        = local.bastion_sg_name
  description = "Security group for bastion host (SSM access only)"
  vpc_id      = aws_vpc.main.id

  
  egress {
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    security_groups   = [aws_security_group.endpoints.id]
    description       = "HTTPS to VPC endpoints (SSM / EC2Messages)"
  }

  tags = { 
  Name = local.bastion_sg_name 
  }
}