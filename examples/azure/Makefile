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

postgresql:
	export ARM_ACCESS_KEY=$(cd bootstrap && $(TF) output -json access_key | jq -r ".access_key")
	cd postgresql \
		&& $(TF) init \
		&& $(TF) apply

inception:
	export ARM_ACCESS_KEY=$(cd bootstrap && $(TF) output -json access_key | jq -r ".access_key")
	bin/prep-inception.sh
	cd inception \
		&& $(TF) init \
		&& $(TF) apply

smoketest:
	bin/prep-smoketest.sh
	cd smoketest \
		&& $(TF) init \
		&& $(TF) apply

destroy-inception:
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

destroy-smoketest:
	cd smoketest \
		&& $(TF) destroy

destroy-postgresql:
	export ARM_ACCESS_KEY=$(cd bootstrap && $(TF) output access_key | jq -r)
	cd postgresql \
		&& $(TF) init \
		&& $(TF) destroy -auto-approve

.PHONY: bootstrap inception platform postgresql smoketest
