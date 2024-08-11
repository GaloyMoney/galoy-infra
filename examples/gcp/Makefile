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
		&& $(TF) apply

smoketest:
	cd smoketest \
		&& $(TF) init \
		&& $(TF) apply

postgresql:
	cd postgresql \
		&& $(TF) init \
		&& $(TF) apply

destroy-inception:
	cd inception \
		&& $(TF) state rm module.inception.google_storage_bucket.tf_state || true
	cd inception \
		&& $(TF) state rm module.inception.google_storage_bucket_iam_policy.policy || true
	cd inception && $(TF) destroy

destroy-smoketest:
	cd smoketest \
		&& $(TF) destroy

destroy-platform:
	cd platform \
		&& $(TF) destroy

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) destroy

destroy-postgresql:
	cd postgresql \
		&& $(TF) destroy || true \
		&& $(TF) state rm module.postgresql.google_sql_user.admin || true \
		&& $(TF) destroy -auto-approve

.PHONY: bootstrap inception platform smoketest postgresql
