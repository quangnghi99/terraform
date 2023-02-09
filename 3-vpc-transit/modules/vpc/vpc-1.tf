#----------------------------------------------------
## VPC
resource "aws_vpc" "vpc_1" {
  cidr_block       = var.vpc_cidr[0]
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc-1"
  }
}

#----------------------------------------------------
## Subnet
resource "aws_subnet" "vpc_1_private_subnet" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = var.vpc_1_subnet_cidr[0]
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = false

  tags = {
    "Name" = "vpc-1-private-subnet"
  }
}

resource "aws_subnet" "vpc_1_public_subnet" {
  vpc_id     = aws_vpc.vpc_1.id
  cidr_block = var.vpc_1_subnet_cidr[1]
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = true

  tags = {
    "Name" = "vpc-1-public-subnet"
  }
}

#----------------------------------------------------
## Internet Gateway
resource "aws_internet_gateway" "vpc_1_igw" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    "Name" = "vpc-1-igw"
  }
}

#----------------------------------------------------
## Route Table
resource "aws_route_table" "vpc_1_public_rt" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_1_igw.id
  }

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    "Name" = "vpc-1-public-rt"
  }
}

resource "aws_route_table_association" "vpc_1_public_association" {
  subnet_id      = aws_subnet.vpc_1_public_subnet.id
  route_table_id = aws_route_table.vpc_1_public_rt.id
}

resource "aws_route_table" "vpc_1_private_rt" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

    tags = {
    "Name" = "vpc-1-private-rt"
  }
}
resource "aws_route_table_association" "vpc_1_private_association" {
  subnet_id      = aws_subnet.vpc_1_private_subnet.id
  route_table_id = aws_route_table.vpc_1_private_rt.id
}

