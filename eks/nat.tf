resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name        = "${local.env}-nat-eip"
    Environment = local.env
  }

}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_zone_1.id

  tags = {
    Name        = "${local.env}-nat-gateway"
    Environment = local.env
  }

  depends_on = [aws_internet_gateway.igw]

}