resource "kubernetes_namespace" "otel" {
  metadata {
    name = local.otel_namespace
  }
}

resource "kubernetes_secret" "honeycomb" {
  metadata {
    name      = "honeycomb-creds"
    namespace = kubernetes_namespace.otel.metadata[0].name
  }
  data = {
    api_key = local.honeycomb_api_key
    dataset = local.name_prefix
  }
}

resource "helm_release" "otel" {
  name       = "opentelemetry-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.6.0"
  namespace  = kubernetes_namespace.otel.metadata[0].name

  values = [
    file("${path.module}/opentelemetry-values.yml"),
    templatefile("${path.module}/opentelemetry-small-footprint.yml.tmpl",
      {
        small_footprint = local.small_footprint
    })
  ]

  depends_on = [
    kubernetes_secret.honeycomb
  ]
}
