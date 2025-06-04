output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Private API server endpoint"
  value       = aws_eks_cluster.primary.endpoint
}

output "cluster_ca_cert" {
  description = "Base64 encoded cluster CA certificate"
  value       = base64decode(aws_eks_cluster.primary.certificate_authority[0].data)
  sensitive   = true
}

output "node_security_group_id" {
  description = "Security group ID for the EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "cluster_subnet_ids" {
  description = "List of subnet IDs where the EKS cluster nodes are deployed"
  value       = [for subnet in aws_subnet.cluster_private : subnet.id]
}

output "irsa_provider_arn" {
  description = "ARN of the OIDC provider for IRSA (IAM Roles for Service Accounts)"
  value       = aws_iam_openid_connect_provider.eks.arn
}  
