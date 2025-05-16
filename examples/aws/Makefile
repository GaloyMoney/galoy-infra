TF := tofu


aws-bootstrap:
	cd bootstrap \
	&& $(TF) init \
	&& $(TF) apply

aws-destroy-bootstrap:
	cd bootstrap \
	&& $(TF) destroy -auto-approve

.PHONY: aws-bootstrap aws-destroy-bootstrap
