#----------------------------------------------------
## VPC 3
resource "aws_vpc" "vpc_3" {
  cidr_block       = var.vpc_cidr[2]
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc-3"
  }
}

#----------------------------------------------------
## Subnet
resource "aws_subnet" "vpc_3_private_subnet" {
  vpc_id     = aws_vpc.vpc_3.id
  cidr_block = var.vpc_3_subnet_cidr[0]
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = false

  tags = {
    "Name" = "vpc-3-private-subnet-1"
  }
}

resource "aws_subnet" "vpc_3_public_subnet" {
  vpc_id     = aws_vpc.vpc_3.id
  cidr_block = var.vpc_3_subnet_cidr[1]
  availability_zone = var.availability_zone[1]
  map_public_ip_on_launch = false

  tags = {
    "Name" = "vpc-3-private-subnet-2"
  }
}

#----------------------------------------------------
## Route Table
resource "aws_route_table" "vpc_3_private_rt" {
  vpc_id = aws_vpc.vpc_3.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

    route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  }

  tags = {
    "Name" = "vpc-3-private-rt"
  }
}

resource "aws_route_table_association" "vpc_3_public_association" {
  subnet_id      = aws_subnet.vpc_3_public_subnet.id
  route_table_id = aws_route_table.vpc_3_private_rt.id
}
resource "aws_route_table_association" "vpc_3_private_association" {
  subnet_id      = aws_subnet.vpc_3_private_subnet.id
  route_table_id = aws_route_table.vpc_3_private_rt.id
}