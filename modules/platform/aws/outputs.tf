output "cluster_name"   { value = aws_eks_cluster.primary.name }
output "cluster_endpoint" {
  description = "Private API server endpoint"
  value       = aws_eks_cluster.primary.endpoint
}
output "cluster_ca_cert" {
  value     = base64decode(aws_eks_cluster.primary.certificate_authority[0].data)
  sensitive = true
}
output "node_security_group_id" {
  value = aws_security_group.nodes.id
}
output "irsa_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}
