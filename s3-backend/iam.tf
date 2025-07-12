data "aws_caller_identity" "current" {}

locals {
    principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
}

data "aws_iam_policy_document" "policy_doc" {
    statement {
        actions = ["s3:ListBucket"]
        resources = [aws_s3_bucket.s3_backend.arn]
    }

    statement {
        actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
        ]
        resources = [
        "${aws_s3_bucket.s3_backend.arn}/*"
        ]
    }
    statement {
        actions = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
        resources = [aws_dynamodb_table.dynamodb_table.arn]
    }
}

resource "aws_iam_policy" "policy" {
    name        = "${var.project}-s3-backend-policy"
    description = "Policy for S3 backend access"
    policy      = data.aws_iam_policy_document.policy_doc.json
    path = "/"
  
}

resource "aws_iam_role" "iam_role" {
    name = "${var.project}-s3-backend-role"
    assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
          "AWS": ${jsonencode(local.principal_arns)}
        },
        "Effect": "Allow"
        }
      ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
    role       = aws_iam_role.iam_role.name
    policy_arn = aws_iam_policy.policy.arn
  
}