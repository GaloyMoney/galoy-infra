moved {
  from = kubernetes_namespace.smoketest
  to   = kubernetes_namespace_v1.smoketest
}

moved {
  from = kubernetes_role.smoketest
  to   = kubernetes_role_v1.smoketest
}

moved {
  from = kubernetes_role_binding.smoketest
  to   = kubernetes_role_binding_v1.smoketest
}

moved {
  from = kubernetes_secret.smoketest_token
  to   = kubernetes_secret_v1.smoketest_token
}

moved {
  from = kubernetes_service_account.smoketest
  to   = kubernetes_service_account_v1.smoketest
}

moved {
  from = kubernetes_secret.concourse_k8s_access_token
  to   = kubernetes_secret_v1.concourse_k8s_access_token
}

moved {
  from = kubernetes_service_account.concourse
  to   = kubernetes_service_account_v1.concourse
}
