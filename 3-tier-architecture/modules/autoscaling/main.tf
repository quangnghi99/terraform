#----------------------------------------------------
## Lauch Template
resource "aws_launch_template" "ec2" {
  name_prefix   = "ec2-"
  image_id      = var.ami_id
  instance_type = "t2.micro"
  key_name = local.key_name
  vpc_security_group_ids = [var.sg]
  user_data = filebase64("${path.module}/userdata.sh")
}

#----------------------------------------------------
## Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "asg" {
  desired_capacity   = 3
  max_size           = 3
  min_size           = 1
  health_check_type         = "EC2"
  vpc_zone_identifier = var.private_subnets
  target_group_arns = [aws_lb_target_group.alb_target_group.arn]

  launch_template {
    id      = aws_launch_template.ec2.id
    version = "$Latest"
  }
}

#----------------------------------------------------
## Application Load Balancer (ALB)
# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name               = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg]
  subnets            = var.public_subnets
  enable_deletion_protection = false

  tags   = {
    Name = "${local.tags}-alb"
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "my-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc.id

  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    timeout             = 6
    matcher             = 200
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80 
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}