TF:=terraform

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) destroy

.PHONY: bootstrap
