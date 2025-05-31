output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [for sn in aws_subnet.public: sn.id]
}

output "nat_gateway_ids" {
   value = [aws_nat_gateway.nat.id]
} 

output "dmz_subnet_ids" { 
  value = [for s in aws_subnet.dmz_private: s.id]
} 

output "bastion_security_group_id" {
  value = aws_security_group.bastion.id
}

output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_hostname" {
  value = aws_instance.bastion.public_dns
}

output "backups_bucket_name" {
  value = aws_s3_bucket.backups.bucket
}

output "cloudtrail_bucket_name" {
  value = aws_s3_bucket.cloudtrail.bucket
}

output "cloudtrail_trail_name" {
  value = aws_cloudtrail.trail.name
}

output "bastion_instance_profile" {
  value = aws_iam_instance_profile.bastion.name
}

output "eks_cluster_role_arn" { 
  value = aws_iam_role.eks_cluster.arn 
}

output "eks_nodes_role_arn"   { 
  value = aws_iam_role.eks_nodes.arn 
}