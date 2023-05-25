locals {
  name         = "${var.project}-${var.slug_version}-${var.env}-${var.s3_purpose}-${local.aws_region}-${random_string.this.result}"
  replica_name = "${var.project}-${var.slug_version}-${var.env}-${var.s3_purpose}-replica-${var.s3_replica_region}-${random_string.this.result}"
  aws_region   = var.region

  replication_configuration = var.s3_with_replication ? {
    role = aws_iam_role.replication[0].arn

    rules = [
      {
        id       = "everything-without-filter"
        status   = "Enabled"
        priority = 30

        delete_marker_replication = true

        # filter = {
        #   prefix = "/"
        # }

        destination = {
          bucket        = "arn:aws:s3:::${local.replica_name}"
          storage_class = "STANDARD"
        }

        // leads to MalformedXML error
        // existing_object_replication = true
      },
    ]
    } : {
    role = aws_iam_role.replication[0].arn

    rules = [
      {
        id       = "everything-without-filter"
        status   = "Disabled"
        priority = 30

        delete_marker_replication = true

        # filter = {
        #   prefix = "/"
        # }

        destination = {
          bucket        = "arn:aws:s3:::${local.replica_name}"
          storage_class = "STANDARD"
        }

        // leads to MalformedXML error
        // existing_object_replication = true
      },
    ]
    }
}

data "aws_caller_identity" "current" {}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.1"

  bucket = local.name

  force_destroy       = var.s3_force_destroy
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
