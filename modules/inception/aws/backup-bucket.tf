resource "aws_s3_bucket" "backups" {
  bucket        = local.backups_bucket_name
  acl           = "private"
  force_destroy = var.backups_bucket_force_destroy

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = {
    Name = local.backups_bucket_name
  }
}
