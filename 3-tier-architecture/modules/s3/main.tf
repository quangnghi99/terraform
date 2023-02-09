# variable "bucketname" {
#   default = "s3nghi.com"
#   type    = string
# }

variable "ami_id" {
  type = any
}

variable "sg" {
  type = any
}

variable "private_subnets" {
  type = any
}

# variable "key_name" {
#   type = any
# }

resource "aws_iam_instance_profile" "instance_profile" {
  name = "s3_instance_profile"
  role = aws_iam_role.iam_role.name
}

# Instance
resource "aws_instance" "ec2_access_S3" {
  ami = var.ami_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.sg]
  subnet_id = var.private_subnets[0]
  key_name = local.key_name
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  tags = {
    "Name" = "ec2_access_S3"
  }
}