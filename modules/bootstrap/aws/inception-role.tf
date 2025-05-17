data "aws_caller_identity" "current" {}

resource "aws_iam_role" "inception" {
  name               = local.inception_role
  assume_role_policy = jsonencode({
    Version   : "2012-10-17",
    Statement : [{
      Effect    : "Allow",
      Principal : { AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
      Action    : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "bootstrap" {
  name        = local.bootstrap_policy
  description = "Minimal permissions for Terraform bootstrap"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      # S3 state bucket
      {
        Effect   : "Allow",
        Action   : "s3:*",
        Resource : [
          aws_s3_bucket.tf_state.arn,
          "${aws_s3_bucket.tf_state.arn}/*"
        ]
      },
      # DynamoDB lock table
      {
        Effect   : "Allow",
        Action   : [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ],
        Resource : aws_dynamodb_table.tf_lock.arn
      },
      # IAM bootstrap for later stacks
      {
        Effect   : "Allow",
        Action   : [
          "iam:CreateRole","iam:DeleteRole","iam:GetRole","iam:UpdateRole",
          "iam:PassRole","iam:*Policy*","iam:AttachRolePolicy","iam:DetachRolePolicy"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "bootstrap" {
  role       = aws_iam_role.inception.name
  policy_arn = aws_iam_policy.bootstrap.arn
}
