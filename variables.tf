//Global variables
variable "project" {
  type = string
}

variable "slug_version" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "s3_purpose" {
  type    = string
  default = "general"
}

variable "s3_force_destroy" {
  type = bool
}

variable "tags" {
  type = map(string)
}

variable "s3_versioning" {
  description = "Boolean specifying enabled state of versioning or object containing detailed versioning configuration."
  type        = any
  default     = false
  # Examples:
  #
  # versioning = true
  # versioning = {
  #   enabled    = true
  #   mfa_delete = true
  # }
}

variable "s3_sse_by_default" {
  description = "Map containing server-side encryption configuration."
  type        = map(any)
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
        // kms_master_key_id = aws_kms_key.objects.arn
        // sse_algorithm     = "aws:kms"
      }
    }
  }
}

variable "s3_lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "s3_with_replication" {
  type    = bool
  default = false
}

variable "s3_replica_region" {
  type    = string
  default = "us-east-1"
}

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

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
    role  = ""
    rules = []
  }
}
