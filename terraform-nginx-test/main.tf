# Ami
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}


resource "aws_instance" "aws_linux" {
  instance_type          = "t2.micro"
  ami                    = "ami-052efd3df9dad4825"
  key_name               = var.key_name
  user_data              = file("userdata.tpl")
}  


# Default VPC
resource "aws_default_vpc" "default" {

}

# Security group
resource "aws_security_group" "demo_sg" {
  name        = "demo_sg"
  description = "allow ssh on 22 & http on port 80"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion_host_1" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name = local.key_name
  vpc_security_group_ids = [aws_security_group.demo_sg]
  associate_public_ip_address = true

  tags = {
    "Name" = "test-nginx"
  }
}