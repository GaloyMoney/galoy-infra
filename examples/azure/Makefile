TF:=terraform

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) destroy

.PHONY: bootstrap inception platform services
