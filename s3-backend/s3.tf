resource "aws_s3_bucket" "s3_backend" {
    bucket = "${var.project}-s3-backend"
    force_destroy = false
  
}

#resource "aws_s3_bucket_acl" "s3_backend_acl" {
#    bucket = aws_s3_bucket.s3_backend.id
#    acl    = "private"
#  
#}

resource "aws_s3_bucket_ownership_controls" "s3_backend" {
  bucket = aws_s3_bucket.s3_backend.id

  rule {
    object_ownership = "BucketOwnerEnforced" 
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket" {
    bucket = aws_s3_bucket.s3_backend.id
    versioning_configuration {
        status = "Enabled"
    }
  
}

resource "aws_kms_key" "s3_backend_key" {
    description = "KMS key for S3 backend encryption"
    tags = {
        Name = "${var.project}-s3-backend-key"
    }
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_backend_encryption" {
    bucket = aws_s3_bucket.s3_backend.id
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "aws:kms"
            kms_master_key_id = aws_kms_key.s3_backend_key.id
        }
    }
  
}