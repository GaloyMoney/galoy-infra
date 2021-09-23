resource "kubernetes_namespace" "smoketest" {
  metadata {
    name = local.smoketest_namespace
  }
}

resource "kubernetes_role" "smoketest" {
  metadata {
    name      = local.smoketest_name
    namespace = kubernetes_namespace.smoketest.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_service_account" "smoketest" {
  metadata {
    name      = local.smoketest_name
    namespace = kubernetes_namespace.smoketest.metadata[0].name
  }
}

data "kubernetes_secret" "smoketest_token" {
  metadata {
    name      = kubernetes_service_account.smoketest.default_secret_name
    namespace = kubernetes_namespace.smoketest.metadata[0].name
  }
}

resource "kubernetes_secret" "testflight_kube_config" {
  metadata {
    name      = "misthos-network.testflight-kube-config"
    namespace = local.concourse_namespace
  }

  data = {
    host    = module.platform.master_endpoint
    token   = data.kubernetes_secret.testflight_token.data.token
    ca_cert = module.platform.cluster_ca_cert
  }
}

resource "kubernetes_role_binding" "smoketest" {
  metadata {
    name      = local.smoketest_name
    namespace = kubernetes_namespace.smoketest.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.smoketest.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.smoketest_name
    namespace = kubernetes_role.smoketest.metadata[0].namespace
  }
}
