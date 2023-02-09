# data "aws_caller_identity" "current" {}

# locals {
#   principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
# }

data "aws_iam_policy_document" "policy_doc" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.s3_bucket.arn]
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.s3_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.bucketname}S3Policy"
  path   = "/"
  policy = data.aws_iam_policy_document.policy_doc.json
}

resource "aws_iam_role" "iam_role" {
  name = "${var.bucketname}S3Role"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
  EOF

  tags = {
    name = "${var.bucketname}_s3_role"
  }
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.policy.arn
}