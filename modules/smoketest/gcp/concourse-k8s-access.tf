resource "kubernetes_service_account" "concourse" {
  count = local.k8s_secret_reader_enabled ? 1 : 0
  metadata {
    name      = "concourse"
    namespace = local.concourse_namespace
  }
}

resource "kubernetes_secret" "concourse_k8s_access_token" {
  count = local.k8s_secret_reader_enabled ? 1 : 0
  metadata {
    name      = "concourse-k8s-service-account-token"
    namespace = local.concourse_namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.concourse[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}
