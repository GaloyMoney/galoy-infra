resource "kubernetes_namespace" "ingress" {
  metadata {
    name = local.ingress_namespace
    labels = {
      type = "ingress-nginx"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = local.ingress_nginx_version
  chart      = "ingress-nginx"

  values = [
    templatefile("${path.module}/ingress-values.yml.tmpl", {
      service_type = local.local_deploy ? "NodePort" : "LoadBalancer"
      jaeger_host  = local.jaeger_host
    })
  ]

  depends_on = [
    helm_release.otel
  ]
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
        solvers = [
          { http01 = { ingress = { class = "nginx" } } }
        ]
      }
    }
  }

  depends_on = [
    helm_release.cert_manager,
  ]
}
