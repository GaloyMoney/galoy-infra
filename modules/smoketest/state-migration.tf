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
