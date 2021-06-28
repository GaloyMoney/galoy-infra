TF:=terraform

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& TF_VAR_name_prefix=$(TF_VAR_name_prefix) $(TF) apply -auto-approve

teardown:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) destroy -auto-approve

.PHONY: bootstrap
