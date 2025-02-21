TF:=tofu

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply
	bin/prep-inception.sh

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) destroy

platform:
	export ARM_ACCESS_KEY=$(cd bootstrap && $(TF) output -json access_key | jq -r ".access_key")
	cd platform \
		&& $(TF) apply

inception:
	export ARM_CLIENT_ID=$(cd bootstrap && $(TF) output client_id | jq -r)
	export ARM_CLIENT_SECRET=$(cd bootstrap && $(TF) output client_secret | jq -r)
	export ARM_TENANT_ID=$(cd bootstrap && $(TF) output tenant_id | jq -r)
	export ARM_SUBSCRIPTION_ID=$(cd bootstrap && $(TF) output subscription_id | jq -r)
	export ARM_ACCESS_KEY=$(cd bootstrap && $(TF) output -json access_key | jq -r ".access_key")
	cd inception \
		&& $(TF) init \
		&& $(TF) apply

destroy-inception:
	export ARM_CLIENT_ID=$(cd bootstrap && $(TF) output client_id | jq -r)
	export ARM_CLIENT_SECRET=$(cd bootstrap && $(TF) output client_secret | jq -r)
	export ARM_TENANT_ID=$(cd bootstrap && $(TF) output tenant_id | jq -r)
	export ARM_SUBSCRIPTION_ID=$(cd bootstrap && $(TF) output subscription_id | jq -r)
	export ARM_ACCESS_KEY=$(cd bootstrap && $(TF) output access_key | jq -r)
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_account.bootstrap || true
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_container.bootstrap || true
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_blob.tf_state || true
	cd inception \
		&& $(TF) destroy

destroy-platform:
	export ARM_ACCESS_KEY=$(cd bootstrap && $(TF) output access_key | jq -r)
	cd platform \
		&& $(TF) destroy


.PHONY: bootstrap inception platform
