resource "aws_security_group" "bastion" {
  name        = local.bastion_sg_name
  description = "Security group for bastion host (SSM access only)"
  vpc_id      = aws_vpc.main.id

  # No SSH ingress - removed port 22 entry to fully secure the bastion
  
  # Allow only necessary outbound traffic
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound for SSM and package updates"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP outbound for package repositories"
  }

  tags = { Name = local.bastion_sg_name }
}