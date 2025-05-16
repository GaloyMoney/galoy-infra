TF := tofu


aws-bootstrap:
	cd bootstrap \
	&& $(TF) init \
	&& $(TF) apply

aws-destroy-bootstrap:
	cd modules/bootstrap/aws \
	&& $(TF) destroy -auto-approve

.PHONY: aws-bootstrap aws-destroy-bootstrap
