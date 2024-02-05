resource "kubernetes_service_account" "concourse" {
  metadata {
    name      = "concourse"
    namespace = local.concourse_namespace
  }
}

resource "kubernetes_role" "lnd_tls_secret_reader" {
  metadata {
    name      = "lnd-tls-secret-reader"
    namespace = local.bitcoin_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_role_binding" "lnd_tls_secret_reader" {
  metadata {
    name      = "lnd-tls-secret-reader"
    namespace = local.concourse_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.concourse_k8s_secret_access.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.concourse_k8s_secret_access.metadata[0].name
    namespace = local.concourse_namespace
  }
}

resource "kubernetes_secret" "concourse_k8s_access_token" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.concourse_k8s_secret_access.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}
