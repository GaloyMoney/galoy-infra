TF:=terraform

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply
	bin/prep-inception.sh

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) destroy

inception:
	export ARM_CLIENT_ID=$(cd bootstrap && terraform output client_id | jq -r)
	export ARM_CLIENT_SECRET=$(cd bootstrap && terraform output client_secret | jq -r)
	export ARM_TENANT_ID=$(cd bootstrap && terraform output tenant_id | jq -r)
	export ARM_SUBSCRIPTION_ID=$(cd bootstrap && terraform output subscription_id | jq -r)
	export ARM_ACCESS_KEY=$(cd bootstrap && terraform output -json access_key | jq -r ".access_key")
	cd inception \
		&& $(TF) init \
		&& $(TF) apply

destroy-inception:
	export ARM_CLIENT_ID=$(cd bootstrap && terraform output client_id | jq -r)
	export ARM_CLIENT_SECRET=$(cd bootstrap && terraform output client_secret | jq -r)
	export ARM_TENANT_ID=$(cd bootstrap && terraform output tenant_id | jq -r)
	export ARM_SUBSCRIPTION_ID=$(cd bootstrap && terraform output subscription_id | jq -r)
	export ARM_ACCESS_KEY=$(cd bootstrap && terraform output access_key | jq -r)
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_account.bootstrap || true
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_container.bootstrap || true
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_blob.tf_state || true
	cd inception \
		&& $(TF) destroy


.PHONY: bootstrap inception
