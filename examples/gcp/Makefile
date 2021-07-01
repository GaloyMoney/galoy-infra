TF:=terraform

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply
	bin/prep-inception.sh

inception:
	cd inception \
		&& $(TF) apply

destroy-inception:
	cd inception \
		&& $(TF) state rm module.inception.google_storage_bucket.tf_state \
		&& $(TF) destroy

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) destroy

teardown: destory-inception destroy-bootstrap

.PHONY: bootstrap inception
