TF := tofu


bootstrap:
	cd bootstrap \
	&& $(TF) init \
	&& $(TF) apply

destroy-bootstrap:
	cd bootstrap \
	&& $(TF) destroy -auto-approve

inception:
	cd inception \
		&& $(TF) apply

inception:
	cd inception \
	&& $(TF) init \
	&& $(TF) apply

destroy-inception:
	cd inception \
	&& $(TF) init \
	&& $(TF) destroy -auto-approve


.PHONY: aws-bootstrap aws-destroy-bootstrap
