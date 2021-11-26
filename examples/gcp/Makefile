TF:=terraform

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply
	bin/prep-inception.sh

inception:
	cd inception \
		&& $(TF) apply

initial-services:
	cd services \
		&& $(TF) init \
		&& $(TF) apply -target module.services.helm_release.cert_manager

platform:
	cd platform \
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

.PHONY: bootstrap inception platform
