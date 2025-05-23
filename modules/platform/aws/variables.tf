variable "name_prefix" {}
variable "region"                 { default = "us-east-1" }
variable "cluster_version"        { default = "1.30" }
variable "node_default_type"      { default = "m6a.large" }
variable "min_default_node_count" { default = 1 }
variable "max_default_node_count" { default = 3 }

# -------- inputs coming from the inception (foundation) layer --------
variable "vpc_id"              { type = string }
variable "private_subnet_ids"  { type = list(string) }
variable "public_subnet_ids"   { type = list(string) }  # the DMZ/public subnets created by inception
variable "bastion_sg_id"       { type = string }
variable "eks_cluster_role_arn" { type = string }
variable "eks_nodes_role_arn"   { type = string }
