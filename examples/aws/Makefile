TF := tofu

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply --auto-approve
	bin/prep-inception.sh

inception:
	bin/prep-inception.sh
	cd inception \
		&& $(TF) init \
		&& $(TF) apply

platform:
	bin/prep-platform.sh
	cd platform \
		&& $(TF) init \
		&& $(TF) apply

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) destroy -auto-approve

destroy-inception:
	cd inception \
		&& $(TF) destroy -auto-approve

destroy-platform:
	cd platform \
		&& $(TF) destroy -auto-approve

.PHONY: bootstrap inception platform destroy-bootstrap destroy-inception destroy-platform
