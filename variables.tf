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


