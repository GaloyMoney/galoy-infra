variable "name_prefix" {}
variable "tenant_id" {}
module "bootstrap" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/azure?ref=b276fd3"
  #source = "../../../modules/bootstrap/azure"

  name_prefix = var.name_prefix
  tenant_id = var.tenant_id
}

output "tf_state_storage_blob_name" {
  value = module.bootstrap.tf_state_storage_blob_name
}
output "tf_state_storage_container" {
  value = module.bootstrap.tf_state_storage_container
}
output "tf_state_storage_location" {
  value = module.bootstrap.tf_state_storage_location
}
output "tf_state_storage_account" {
  value = module.bootstrap.tf_state_storage_account
}
output "resource_group_name" {
  value = module.bootstrap.resource_group
}
output "application_id" {
  value = module.bootstrap.application_id
}
output "client_secret" {
  value     = module.bootstrap.client_secret
  sensitive = true
}
output "tenant_id" {
  value = module.bootstrap.tenant_id
}
output "subscription_id" {
  value = module.bootstrap.subscription_id
}
output "name_prefix" {
  value = module.bootstrap.name_prefix
}
