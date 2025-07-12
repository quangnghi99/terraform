resource "aws_iam_role" "nodes" {
  name = "${local.env}-${local.eks_cluster_name}-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${local.env}-nodes-role"
    Environment = local.env
  }
}

resource "aws_iam_role_policy_attachment" "aws_eks_worker_node_policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

resource "aws_iam_role_policy_attachment" "aws_eks_cni_policy" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}

resource "aws_iam_role_policy_attachment" "aws_ec2_container_registry_read_only" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${local.env}-${local.eks_cluster_name}-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  version = local.eks_version

  subnet_ids = [
    aws_subnet.private_zone_1.id,
    aws_subnet.private_zone_2.id
  ]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.aws_ec2_container_registry_read_only
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    Name        = "${local.env}-nodes"
    Environment = local.env
  }

}