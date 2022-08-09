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
		&& $(TF) init \
		&& $(TF) destroy


.PHONY: bootstrap inception
