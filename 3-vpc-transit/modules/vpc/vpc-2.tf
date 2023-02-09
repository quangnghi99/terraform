#----------------------------------------------------
## VPC 2
resource "aws_vpc" "vpc_2" {
  cidr_block       = var.vpc_cidr[1]
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc-2"
  }
}

#----------------------------------------------------
## Subnet
resource "aws_subnet" "vpc_2_private_subnet" {
  vpc_id     = aws_vpc.vpc_2.id
  cidr_block = var.vpc_2_subnet_cidr[0]
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = false

  tags = {
    "Name" = "vpc-2-private-subnet"
  }
}

resource "aws_subnet" "vpc_2_public_subnet" {
  vpc_id     = aws_vpc.vpc_2.id
  cidr_block = var.vpc_2_subnet_cidr[1]
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = true

  tags = {
    "Name" = "vpc-2-public-subnet"
  }
}

#----------------------------------------------------
## Internet Gateway
resource "aws_internet_gateway" "vpc_2_igw" {
  vpc_id = aws_vpc.vpc_2.id

  tags = {
    "Name" = "vpc-2-igw"
  }
}

#----------------------------------------------------
## NAT Gateway
resource "aws_eip" "nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.vpc_2_public_subnet.id

    tags = {
    "Name" = "vpc-2-nat-gw"
  }
}

#----------------------------------------------------
## Route Table
resource "aws_route_table" "vpc_2_private_rt" {
  vpc_id = aws_vpc.vpc_2.id

  # Nat gateway
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  
  # Transit gateway
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    "Name" = "vpc-2-private-rt"
  }
}

resource "aws_route_table_association" "vpc_2_private_association" {
  subnet_id      = aws_subnet.vpc_2_private_subnet.id
  route_table_id = aws_route_table.vpc_2_private_rt.id
}


resource "aws_route_table" "vpc_2_public_rt" {
  vpc_id = aws_vpc.vpc_2.id

  #igw
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_2_igw.id
  }

  # Transit gateway
  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    "Name" = "vpc-2-public-rt"
  }
}

resource "aws_route_table_association" "vpc_2_public_association" {
  subnet_id      = aws_subnet.vpc_2_public_subnet.id
  route_table_id = aws_route_table.vpc_2_public_rt.id
}