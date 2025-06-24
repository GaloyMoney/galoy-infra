variable "name_prefix" {}
module "bootstrap" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/azure?ref=80052e7"
  # source = "../../../modules/bootstrap/azure"

  name_prefix = var.name_prefix
}

output "tf_state_storage_container" {
  value = module.bootstrap.tf_state_storage_container
}
output "tf_state_storage_account" {
  value = module.bootstrap.tf_state_storage_account
}
output "resource_group_name" {
  value = module.bootstrap.resource_group
}
output "client_id" {
  value = module.bootstrap.client_id
}
output "client_secret" {
  value     = module.bootstrap.client_secret
  sensitive = true
}
output "subscription_id" {
  value = module.bootstrap.subscription_id
}
output "name_prefix" {
  value = module.bootstrap.name_prefix
}
output "access_key" {
  value     = module.bootstrap.tf_state_access_key
  sensitive = true
}
output "inception_sp_id" {
  value = module.bootstrap.inception_sp_id
}
