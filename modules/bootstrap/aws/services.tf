locals {
  apis = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "ssm.amazonaws.com",
    "servicecatalog.amazonaws.com",
    "ram.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
    "securityhub.amazonaws.com",
    "access-analyzer.amazonaws.com",
    "wellarchitected.amazonaws.com"
  ]
}


resource "aws_organizations_organization" "this" {
  aws_service_access_principals = var.enable_services ? local.apis : []
}
