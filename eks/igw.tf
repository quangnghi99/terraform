resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name        = "${local.env}-igw"
    Environment = local.env
  }
}