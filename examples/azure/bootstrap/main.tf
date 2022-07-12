variable "name_prefix" {}

module "bootstrap" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/bootstrap/azure?ref=b276fd3"
  # source = "../../../modules/bootstrap/azure"

  name_prefix = var.name_prefix
}

output "tf_state_storage_blob_name" {
  value = module.bootstrap.tf_state_storage_blob_name
}
output "tf_state_storage_location" {
  value = module.bootstrap.tf_state_storage_location
}
output "tf_state_storage_account" {
  value = module.bootstrap.tf_state_storage_account
}
