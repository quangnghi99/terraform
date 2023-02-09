#----------------------------------------------------
## Database subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = var.database_subnets

  tags = {
    Name = "${local.tags}-database"
  }
}

#----------------------------------------------------
## Database security group
resource "aws_security_group" "database_sg" {
  name        = "Database-SG"
  description = "Allow inbound traffic from application layer"
  vpc_id      = var.vpc.id

  ingress {
    description     = "Allow traffic from application layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.sg]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.tags}-database-sg"
  }
}

#----------------------------------------------------
## Database instance
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_db_instance" "database_instance" {
  allocated_storage      = 20
  engine                 = "MySQL"
  engine_version         = "8.0.28"
  instance_class         = "db.t2.micro"
  identifier             = "my-db-instance"
  db_name                = "nghi"
  username               = "nghi"
  password               = random_password.password.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  skip_final_snapshot    = true
}