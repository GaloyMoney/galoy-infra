TF:=terraform

init:
	cd bootstrap \
		&& $(TF) init

bootstrap:
	cd bootstrap \
		&& TF_VAR_name_prefix=$(TF_VAR_name_prefix) $(TF) apply -auto-approve

teardown:
	cd bootstrap \
		&& $(TF) destroy -auto-approve

.PHONY: bootstrap
