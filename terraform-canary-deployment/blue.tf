# EC2 Instance
resource "aws_instance" "blue" {
  count = var.enable_blue_env ? var.blue_instance_count : 0

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = templatefile("${path.module}/init-script.sh", {
    file_content = "blue version 1.0 - ${count.index}"
  })

  tags = {
    Name = "blue version 1.0 - ${count.index}"
  }
}

# Load Balancer Target Group
resource "aws_lb_target_group" "blue" {
  name     = "blue-tg-blue-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

# Load Balancer Target Group Attachment
resource "aws_lb_target_group_attachment" "blue" {
  count            = length(aws_instance.blue)
  target_group_arn = aws_lb_target_group.blue.arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}