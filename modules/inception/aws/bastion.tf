data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


locals {
  bastion_user_data = templatefile("${path.module}/bastion-startup.tmpl", {
    opentofu_version = local.opentofu_version
    region          = local.region
    cluster_name    = local.cluster_name
    project         = local.name_prefix
    kubectl_version = local.kubectl_version
    bria_version    = local.bria_version
    cepler_version  = local.cepler_version
    bitcoin_version = local.bitcoin_version
    k9s_version     = local.k9s_version
    kratos_version  = local.kratos_version
    bos_version     = local.bos_version
    bastion_revoke_on_exit = local.bastion_revoke_on_exit
  })
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = local.bastion_instance_type
  subnet_id = aws_subnet.dmz_private[ local.azs_dmz_keys[0] ].id
  associate_public_ip_address = false 
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name
  user_data              = local.bastion_user_data
  tags                   = { 
    Name = "${local.prefix}-bastion"
    SSMManaged = "true"
  }
  
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" 
  }
}