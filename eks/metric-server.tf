resource "helm_release" "metric_server" {
  name       = "metric-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.2"

  values = [file("${path.module}/values/metric-server.yaml")]

  depends_on = [aws_eks_node_group.general]

  # Optional: Configure the provider to use a specific namespace
  # namespace = "kube-system"

}