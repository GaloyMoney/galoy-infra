output "inception_role_arn" {
  value = aws_iam_role.inception.arn
}

output "tf_state_bucket_name" {
  value = aws_s3_bucket.tf_state.id
}

output "tf_lock_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}

output "aws_region" {
  value = local.region
}
