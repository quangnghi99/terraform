resource "aws_iam_user" "developer" {
  name = "developer"

}

resource "aws_iam_policy" "developer_policy" {
  name = "developer-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "developer_eks" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.developer_policy.arn

}

resource "aws_eks_access_entry" "developer_access" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = aws_iam_user.developer.arn
  kubernetes_groups = ["viewer"]

}