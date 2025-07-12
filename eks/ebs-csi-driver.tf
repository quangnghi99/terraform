data "aws_iam_policy_document" "ebs_csi_driver_policy" {
  statement {
    effect = "Allow"

    actions = [
        "sts:AssumeRole",
        "sts:TagSession",
    ]

    principals {
        type        = "Service"
        identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name               = "ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_policy.json
  
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  
}

# Optional: If you want to encrypt the EBS volumes
resource "aws_iam_policy" "ebs_csi_driver_encryption" {
  name        = "${aws_eks_cluster.eks.name}ebs-csi-driver-encryption-policy"
  description = "Policy to allow EBS CSI driver to encrypt volumes"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
            "kms:CreateGrant",
            "kms:GenerateDataKeyWithoutPlaintext",
            "kms:CreateKey",
        ]
        Resource = "*"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_encryption_attachment" {
    role       = aws_iam_role.ebs_csi_driver_role.name
    policy_arn = aws_iam_policy.ebs_csi_driver_encryption.arn
  
}

resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
    cluster_name    = aws_eks_cluster.eks.name
    role_arn        = aws_iam_role.ebs_csi_driver_role.arn
    namespace       = "kube-system"
    service_account = "ebs-csi-controller-sa"
}

resource "aws_eks_addon" "ebs_csi_driver" {
    cluster_name = aws_eks_cluster.eks.name
    addon_name   = "aws-ebs-csi-driver"
    addon_version = "v1.21.0-eksbuild.1" # Specify the version you want to use
    service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
  
}