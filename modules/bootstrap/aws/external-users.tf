
resource "aws_organizations_policy" "external_users" {
  count       = local.organization_id != "" ? 1 : 0
  name        = "${local.name_prefix}-external-users-policy"
  description = "Policy granting external AWS accounts limited EC2/SSM access"
  type        = "SERVICE_CONTROL_POLICY"

  content = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:StartSession",
        "ssm:SendCommand"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_organizations_policy_attachment" "external_users" {
  for_each  = local.organization_id != "" ? toset(local.external_users) : toset([])

  policy_id = aws_organizations_policy.external_users[0].id
  target_id = each.key
}
