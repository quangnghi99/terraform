resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.18.2"

  set ={
    name  = "installCRDs"
    value = true
  }


  depends_on = [helm_release.external_nginx_ingress]
  
}