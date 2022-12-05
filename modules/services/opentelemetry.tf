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
  version    = "0.40.7"
  namespace  = kubernetes_namespace.otel.metadata[0].name

  values = [
    templatefile("${path.module}/opentelemetry-values.yml", {
      trace_sample_pct : local.trace_sample_pct,
    }),
    local.small_footprint ? file("${path.module}/opentelemetry-small-footprint.yml") : ""
  ]

  depends_on = [
    kubernetes_secret.honeycomb
  ]
}
