provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "app" {
  length    = 2
  separator = "-"
}


output "dns" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
