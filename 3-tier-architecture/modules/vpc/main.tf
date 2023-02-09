#----------------------------------------------------
## VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  
  tags = {
    Name = "${local.tags}-vpc"
  }
}

#----------------------------------------------------
## Subnet
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "public-subnet"
  }
}

resource "aws_subnet" "database_subnets" {
  count = length(var.database_subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = var.availability_zone[count.index % length(var.availability_zone)]

  tags = {
    "Name" = "database-subnet"
  }
}

#----------------------------------------------------
## Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "igw"
  }
}

#----------------------------------------------------
## Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table_association" "public_association" {
  for_each       = { for k, v in aws_subnet.public_subnets : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_private" {
  for_each       = { for k, v in aws_subnet.private_subnets : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

#----------------------------------------------------
## NAT Gateway
resource "aws_eip" "nat" {
  #elastic ip
  vpc = true
}

resource "aws_nat_gateway" "public" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "Public NAT"
  }
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
## EC2 Instance
# Bastion Host
resource "aws_instance" "bastion_host_1" {
  ami = data.aws_ami.ami.id
  instance_type = var.instance_type
  key_name = local.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true

  tags = {
    "Name" = "${local.tags}-bastion-host"
  }
}

# # Private instance
# resource "aws_instance" "ec2_private" {
#   ami = data.aws_ami.ami.id
#   instance_type = "t2.micro"
#   key_name = aws_key_pair.generated_key.key_name
#   vpc_security_group_ids = [aws_security_group.private_sg.id]
#   subnet_id = aws_subnet.private_subnets[0].id

#   tags = {
#     "Name" = "my_private"
#   }
# }
