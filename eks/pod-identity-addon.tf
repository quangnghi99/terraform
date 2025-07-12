resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.8-eksbuild.2" # Specify the version you want to use

  # Optional: Specify the service account ARN if needed
  # service_account_role_arn = aws_iam_role.pod_identity_role.arn

  depends_on = [aws_eks_node_group.general]

}