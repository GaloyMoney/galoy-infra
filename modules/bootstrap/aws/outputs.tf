
output "inception_user_name" {
  description = "Name of the inception IAM user"
  value       = aws_iam_user.inception.name
}

output "inception_user_arn" {
  description = "ARN of the inception IAM user"
  value       = aws_iam_user.inception.arn
}

output "bootstrap_policy_arn" {
  description = "ARN of the bootstrap IAM policy"
  value       = aws_iam_policy.bootstrap.arn
}

output "tf_state_bucket_name" {
  description = "Name of the S3 bucket holding Terraform state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "tf_state_bucket_arn" {
  description = "ARN of the S3 bucket holding Terraform state"
  value       = aws_s3_bucket.tf_state.arn
}

output "external_users_policy_id" {
  description = "Organizations policy ID for external users, if defined"
 value       = length(aws_organizations_policy.external_users) > 0 ? aws_organizations_policy.external_users[0].id        : ""
}

output "enabled_services" {
  description = "List of AWS services registered in the Organization"
  value       = var.enable_services ? local.apis : []
}
