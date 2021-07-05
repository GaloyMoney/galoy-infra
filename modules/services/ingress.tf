resource "kubernetes_namespace" "ingress" {
  metadata {
    name = local.ingress_namespace
  }
}

resource "helm_release" "ingress_nginx" {
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = local.ingress_nginx_version
  chart      = "ingress-nginx"
}

resource "helm_release" "cert_manager" {
  namespace  = helm_release.ingress_nginx.namespace
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = local.cert_manager_version
  chart      = "cert-manager"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_manifest" "issuer" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-issuer"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = local.letsencrypt_issuer_email
        privateKeySecretRef = {
          name = "letsencrypt-issuer"
        }
        "solvers" = [
          { http01 = {
            ingress = {
    class = "nginx" } } }] } }
  }

  depends_on = [
    helm_release.cert_manager,
  ]
}
