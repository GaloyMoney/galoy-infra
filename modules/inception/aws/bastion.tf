data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


locals {
  bastion_user_data = templatefile("${path.module}/bastion-startup.tmpl", {})
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.bastion_instance_type
  subnet_id              = aws_subnet.private[local.private_subnet_names[0]].id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  user_data              = local.bastion_user_data
  tags                   = { 
    Name = "${local.prefix}-bastion"
    SSMManaged = "true"
  }
  
  # Enable IMDSv2 for enhanced security
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # Enforce IMDSv2
  }
}