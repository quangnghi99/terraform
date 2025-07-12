resource "aws_iam_role" "eks" {
  name = "${local.env}-${local.eks_cluster_name}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${local.env}-eks-role"
    Environment = local.env
  }

}

resource "aws_iam_role_policy_attachment" "eks" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

resource "aws_eks_cluster" "eks" {
  name     = "${local.env}-${local.eks_cluster_name}"
  role_arn = aws_iam_role.eks.arn

  version = local.eks_version

  vpc_config {
    subnet_ids = [
      aws_subnet.private_zone_1.id,
      aws_subnet.private_zone_2.id
    ]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks]

  tags = {
    Name        = "${local.env}-eks-cluster"
    Environment = local.env
  }

}