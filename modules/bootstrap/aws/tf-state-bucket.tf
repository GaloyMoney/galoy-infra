
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tf_state" {
  bucket        = local.tf_state_bucket_name
  acl           = "private"
  force_destroy = local.tf_state_bucket_force_destroy

  tags = {
    Name               = local.tf_state_bucket_name
    TerraformBootstrap = "true"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "inception" {
  bucket = aws_s3_bucket.tf_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowInceptionFullAccess"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_user.inception.arn }
        Action    = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.tf_state.arn,
          "${aws_s3_bucket.tf_state.arn}/*"
        ]
      }
    ]
  })
}
