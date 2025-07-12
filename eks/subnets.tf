resource "aws_subnet" "private_zone_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = local.zone_1

  tags = {
    Name                                                           = "${local.env}-private-subnet-1"
    Environment                                                    = local.env
    "kubernetes.io/role/internal-elb"                              = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_cluster_name}" = "owner"

  }

}

resource "aws_subnet" "private_zone_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = local.zone_2

  tags = {
    Name                                                           = "${local.env}-private-subnet-2"
    Environment                                                    = local.env
    "kubernetes.io/role/internal-elb"                              = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_cluster_name}" = "owner"

  }

}

resource "aws_subnet" "public_zone_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = local.zone_1
  map_public_ip_on_launch = true

  tags = {
    Name                                                           = "${local.env}-public-subnet-1"
    Environment                                                    = local.env
    "kubernetes.io/role/elb"                                       = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_cluster_name}" = "owner"
  }
}

resource "aws_subnet" "public_zone_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = local.zone_2
  map_public_ip_on_launch = true

  tags = {
    Name                                                           = "${local.env}-public-subnet-2"
    Environment                                                    = local.env
    "kubernetes.io/role/elb"                                       = "1"
    "kubernetes.io/cluster/${local.env}-${local.eks_cluster_name}" = "owner"
  }
}