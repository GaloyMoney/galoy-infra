TF:=terraform

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply
	bin/prep-inception.sh

inception:
	cd inception \
		&& $(TF) apply

platform:
	cd platform \
		&& $(TF) init \
		&& $(TF) apply

destroy-inception:
	cd inception \
		&& $(TF) state rm module.inception.google_storage_bucket.tf_state || true
	cd inception \
		&& $(TF) state rm module.inception.google_storage_bucket_iam_policy.policy || true
	cd inception && $(TF) destroy

destroy-platform:
	cd platform \
		&& $(TF) destroy

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) destroy

prep-bastion:
	bin/prep-bastion.sh

teardown: destroy-inception destroy-bootstrap

.PHONY: bootstrap inception platform
