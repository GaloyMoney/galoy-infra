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
	cd inception \
		&& $(TF) init \
		&& $(TF) apply

destroy-inception:
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_account.bootstrap || true
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_container.bootstrap || true
	cd inception \
		&& $(TF) state rm module.inception.azurerm_storage_blob.tf_state || true
	cd inception \
		&& $(TF) destroy


.PHONY: bootstrap inception
