project      = "s3-module"
slug_version = "001"
env          = "test"
region       = "eu-west-1"
aws_profile  = "default"
s3_replica_region = "eu-central-1"
s3_purpose        = "artifacts"
s3_force_destroy  = false
s3_versioning = {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
s3_with_replication = true
tags = {
    created = "terraform"
}