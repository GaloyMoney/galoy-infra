resource "kubernetes_namespace" "ingress" {
  metadata {
    name = local.ingress_namespace
  }
}

resource "helm_release" "ingress-nginx" {
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = local.ingress_nginx_version
  chart      = "ingress-nginx"
}

resource "helm_release" "cert_manager" {
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = cert_manager_version
  chart      = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
}
