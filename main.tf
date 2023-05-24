data "aws_caller_identity" "current" {}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.1"

  bucket = local.name

  force_destroy       = var.s3_force_destroy
  acceleration_status = "Suspended"
  request_payer       = "BucketOwner"

  tags = var.tags

  expected_bucket_owner = data.aws_caller_identity.current.account_id

  versioning = {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }

  server_side_encryption_configuration = var.s3_sse_by_default

  lifecycle_rule = var.s3_lifecycle_rules

  replication_configuration = local.replication_configuration

}

module "replica_bucket" {
  count = var.s3_with_replication ? 1 : 0

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.1"

  providers = {
    aws = aws.replica
  }

  bucket = local.replica_name

  versioning = {
    enabled = true
  }

}
