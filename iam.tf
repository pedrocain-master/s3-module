resource "aws_iam_role" "replication" {
  count = var.s3_with_replication ? 1 : 0
  name  = "s3-replica-${random_string.this.result}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  count = var.s3_with_replication ? 1 : 0
  name  = "s3-replica-${random_string.this.result}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.name}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.name}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.replica_name}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  count      = var.s3_with_replication ? 1 : 0
  name       = "s3-replica-${random_string.this.result}"
  roles      = [aws_iam_role.replication[count.index].name]
  policy_arn = aws_iam_policy.replication[count.index].arn
}
