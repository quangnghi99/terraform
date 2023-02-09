provider "aws" {
  region = "us-east-1"
}

variable "bucketname" {
  default = "s3nghi.com"
  type    = string
}

locals {
  mime_types = {
    html = "text/html"
  }
}