provider "aws" {
  region = "us-east-1"
}
#----------------------------------------------------
## VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc"
  }
}
#----------------------------------------------------
## Subnet
resource "aws_subnet" "vpc_private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    "Name" = "vp1-private-subnet"
  }
}

resource "aws_subnet" "vpc_public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "vpc-public-subnet"
  }
}

#----------------------------------------------------
## Internet Gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "vpc-1-igw"
  }
}

#----------------------------------------------------
## Route Table
resource "aws_route_table" "vpc_public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = {
    "Name" = "vpc-public-rt"
  }
}

resource "aws_route_table_association" "vpc_public_association" {
  subnet_id      = aws_subnet.vpc_public_subnet.id
  route_table_id = aws_route_table.vpc_public_rt.id
}

resource "aws_route_table" "vpc_private_rt" {
  vpc_id = aws_vpc.vpc.id

    tags = {
    "Name" = "vpc-private-rt"
  }
}
resource "aws_route_table_association" "vpc_private_association" {
  subnet_id      = aws_subnet.vpc_private_subnet.id
  route_table_id = aws_route_table.vpc_private_rt.id
}

#----------------------------------------------------
## AMI
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

#----------------------------------------------------
## Instance 
# Security Group
resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg"
  }
}

# Public Instance 
resource "aws_instance" "public" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name = "nghi_key"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.vpc_public_subnet.id
  associate_public_ip_address = true
  user_data                   = file("userdata.sh")

  tags = {
    "Name" = "public-ec2"
  }
}

# Private Instance
resource "aws_instance" "private" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name = "nghi_key"
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.vpc_private_subnet.id
  associate_public_ip_address = false

  tags = {
    "Name" = "private-ec2"
  }
}