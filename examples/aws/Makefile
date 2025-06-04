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

postgresql:
	@bin/postgresql.sh shell

smoketest:
	cd smoketest \
		&& $(TF) init \
		&& $(TF) apply

destroy-postgresql:
	@bin/postgresql.sh destroy

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) destroy -auto-approve

destroy-inception:
	cd inception \
		&& $(TF) destroy -auto-approve

destroy-platform:
	cd platform \
		&& $(TF) destroy -auto-approve

destroy-smoketest:
	cd smoketest \
		&& $(TF) destroy

.PHONY: bootstrap inception platform postgresql smoketest postgresql-destroy destroy-bootstrap destroy-inception destroy-platform destroy-smoketest
