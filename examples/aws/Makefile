TF := tofu


bootstrap:
	cd bootstrap \
	&& $(TF) init \
	&& $(TF) apply

destroy-bootstrap:
	cd bootstrap \
	&& $(TF) destroy -auto-approve

.PHONY: aws-bootstrap aws-destroy-bootstrap
