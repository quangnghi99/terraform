provider "aws" {
  region = "us-east-1"
}
locals {
    name = "nghi"
    traffic_dist_map = {
        blue = {
            blue  = 100
            green = 0
        }
        blue-90 = {
            blue  = 90
            green = 10
        }
        split = {
            blue  = 50
            green = 50
        }
        green-90 = {
            blue  = 10
            green = 90
        }
        green = {
            blue  = 0
            green = 100
        }
    }
}

#VPC
data "aws_availability_zones" "available" {
    state = "available"
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"

    name = "${local.name}-vpc"
    cidr= var.vpc_cidr
    azs  = data.aws_availability_zones.available.names
    private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
    public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)

    enable_nat_gateway = false
    enable_vpn_gateway = false
}
# Security Group
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web-servers with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Application Load Balancer
# At least two subnets in two different Availability Zones must be specified
resource "aws_lb" "app" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.web.id]
}

# Load Balancer Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
    # forward {
    #   target_group {
    #     arn    = aws_lb_target_group.blue.arn
    #     weight = lookup(local.traffic_dist_map[var.traffic_distribution], "blue", 100)
    #   }

    #   target_group {
    #     arn    = aws_lb_target_group.green.arn
    #     weight = lookup(local.traffic_dist_map[var.traffic_distribution], "green", 0)
    #   }

    #   stickiness {
    #     enabled  = false
    #     duration = 1
    #   }
    # }
  }
}