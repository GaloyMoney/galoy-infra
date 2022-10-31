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

resource "kubernetes_cluster_role" "smoketest" {
  metadata {
    name = local.smoketest_name
  }

  rule {
    api_groups = ["kafka.strimzi.io"]
    resources  = ["kafkatopics"]
    verbs      = ["get", "create", "delete"]
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

resource "kubernetes_cluster_role_binding" "smoketest" {
  metadata {
    name = local.smoketest_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.smoketest.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.smoketest_name
    namespace = kubernetes_role.smoketest.metadata[0].namespace
  }
}

resource "kubernetes_role" "cronjob" {
  count = local.smoketest_cronjob ? 1 : 0
  metadata {
    name      = local.smoketest_cronjob_name
    namespace = local.galoy_namespace
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["create", "delete", "get", "list"]
  }
}

resource "kubernetes_role_binding" "cronjob" {
  count = local.smoketest_cronjob ? 1 : 0
  metadata {
    name      = local.smoketest_cronjob_name
    namespace = local.galoy_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cronjob[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.smoketest_name
    namespace = kubernetes_role.smoketest.metadata[0].namespace
  }
}
