resource "aws_iam_user" "external" {
  for_each = toset(var.external_users)
  name     = replace(each.key, "@", "_")
}

resource "aws_iam_user_policy_attachment" "external_ec2_connect" {
  for_each   = aws_iam_user.external
  user       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2InstanceConnect"
}
