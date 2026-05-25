# The Kubernetes provider's legacy resources (for example
# kubernetes_namespace) and v1 resources (for example
# kubernetes_namespace_v1) are distinct Terraform resource types, so OpenTofu
# cannot migrate between them with `moved` blocks. Forget the legacy state
# addresses, then import the existing Kubernetes objects into their v1
# addresses so the remote objects are retained while the state adopts the new
# structure.
removed {
  from = kubernetes_namespace.smoketest
}

removed {
  from = kubernetes_role.smoketest
}

removed {
  from = kubernetes_role_binding.smoketest
}

removed {
  from = kubernetes_secret.smoketest_token
}

removed {
  from = kubernetes_service_account.smoketest
}

removed {
  from = kubernetes_secret.concourse_k8s_access_token
}

removed {
  from = kubernetes_service_account.concourse
}

import {
  to = kubernetes_namespace_v1.smoketest
  id = local.smoketest_namespace
}

import {
  to = kubernetes_role_v1.smoketest
  id = "${local.smoketest_namespace}/${local.smoketest_name}"
}

import {
  to = kubernetes_role_binding_v1.smoketest
  id = "${local.smoketest_namespace}/${local.smoketest_name}"
}

import {
  to = kubernetes_secret_v1.smoketest_token
  id = "${local.smoketest_namespace}/${local.smoketest_name}-token"
}

import {
  to = kubernetes_service_account_v1.smoketest
  id = "${local.smoketest_namespace}/${local.smoketest_name}"
}

import {
  for_each = local.k8s_secret_reader_enabled ? toset(["concourse"]) : toset([])

  to = kubernetes_secret_v1.concourse_k8s_access_token[0]
  id = "${local.concourse_namespace}/concourse-k8s-service-account-token"
}

import {
  for_each = local.k8s_secret_reader_enabled ? toset(["concourse"]) : toset([])

  to = kubernetes_service_account_v1.concourse[0]
  id = "${local.concourse_namespace}/concourse"
}
