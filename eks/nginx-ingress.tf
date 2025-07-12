resource "helm_release" "external_nginx_ingress" {
  name = "external-nginx-ingress"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.13.0"

  values = [
    file("${path.module}/values/nginx-ingress.yaml")
  ]

  depends_on = [helm_release.aws_lbc]
}