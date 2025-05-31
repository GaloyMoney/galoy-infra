resource "aws_security_group" "bastion" {
  name        = local.bastion_sg_name
  description = "Security group for bastion host (SSM access only)"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = { 
    Name = local.bastion_sg_name 
  }
}