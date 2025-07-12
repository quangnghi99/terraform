data "aws_iam_policy_document" "lbc_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_lbc_role" {
  name               = "${aws_eks_cluster.eks.name}-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.lbc_assume_role_policy.json
}

resource "aws_iam_policy" "aws_lbc_policy" {
  policy = file("./iam/aws-load-balancer-controller.json")
  name   = "${aws_eks_cluster.eks.name}-aws-lbc-policy"

}

resource "aws_iam_role_policy_attachment" "aws_lbc_attachment" {
  role       = aws_iam_role.aws_lbc_role.name
  policy_arn = aws_iam_policy.aws_lbc_policy.arn

}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = aws_eks_cluster.eks.name
  role_arn        = aws_iam_role.aws_lbc_role.arn
  service_account = "aws-load-balancer-controller"
  namespace       = "kube-system"

}

resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.9.2"

  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.eks.name
    },

    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "vpcId"
      value = aws_vpc.eks_vpc.id
    }
  ]
  depends_on = [helm_release.cluster_autoscaler]

}