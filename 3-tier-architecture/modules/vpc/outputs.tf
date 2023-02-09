output "vpc" {
  value = aws_vpc.vpc
}

output "sg_id" {
  value = aws_security_group.private_sg.id
}

output "private_subnets" {
  value = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id, aws_subnet.private_subnets[2].id]
}

output "public_subnets" {
  value = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id, aws_subnet.public_subnets[2].id]
}

output "database_subnets" {
  value = [aws_subnet.database_subnets[0].id, aws_subnet.database_subnets[1].id, aws_subnet.database_subnets[2].id]
}

output "ami_id" {
  value = data.aws_ami.ami.id
}
