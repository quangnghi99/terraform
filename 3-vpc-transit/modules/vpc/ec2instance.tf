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
## Bastion Host VPC 1
# Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH inbound connections"
  vpc_id = aws_vpc.vpc_1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}

# Instance
resource "aws_instance" "bastion_host" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id = aws_subnet.vpc_1_public_subnet.id
  associate_public_ip_address = true

  tags = {
    "Name" = "bastion_host"
  }
}

#----------------------------------------------------
## Instance VPC 1
# Security Group
resource "aws_security_group" "vpc_1_sg" {
  name        = "vpc_1_sg"
  description = "vpc_1_sg"
  vpc_id      = aws_vpc.vpc_1.id

  # HTTP/S and SSH from the internet
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

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
}

# Instance
resource "aws_instance" "vpc_1_ec2" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.vpc_1_sg.id]
  subnet_id = aws_subnet.vpc_1_private_subnet.id
  associate_public_ip_address = false

  tags = {
    "Name" = "vpc-1-ec2"
  }
}

#----------------------------------------------------
## Instance VPC 2
# Security Group
resource "aws_security_group" "vpc_2_sg" {
  name        = "vpc_2_sg"
  description = "vpc_2_sg"
  vpc_id      = aws_vpc.vpc_2.id

  # HTTP/S and SSH from the internet
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
    cidr_blocks = ["10.0.0.0/8"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance
resource "aws_instance" "vpc_2_ec2" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.vpc_2_sg.id]
  subnet_id = aws_subnet.vpc_2_private_subnet.id
  associate_public_ip_address = false

  tags = {
    "Name" = "vpc-2-ec2"
  }
}

#----------------------------------------------------
## Instance VPC 3
# Security Group
resource "aws_security_group" "vpc_3_sg" {
  name        = "vpc_3_sg"
  description = "vpc_3_sg"
  vpc_id      = aws_vpc.vpc_3.id

  # HTTP/S, SSH and ICMP from the internet
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
    cidr_blocks = ["10.0.0.0/8"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance
resource "aws_instance" "vpc_3_ec2" {
  ami = data.aws_ami.ami.id
  instance_type = "t2.micro"
  key_name = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.vpc_3_sg.id]
  subnet_id = aws_subnet.vpc_3_private_subnet.id
  associate_public_ip_address = false
  user_data                   = file("${path.module}/userdata-vpc-3.sh")

  tags = {
    "Name" = "vpc-3-ec2"
  }
}