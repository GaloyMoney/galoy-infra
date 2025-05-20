TF := tofu


bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply -auto-approve
	bin/prep-inception.sh

destroy-bootstrap:
	cd bootstrap \
	&& $(TF) destroy -auto-approve

inception:
	bin/prep-inception.sh
	cd inception \
		&& $(TF) init \
		&& $(TF) apply

destroy-inception:
	bin/prep-inception.sh
	cd inception \
		&& $(TF) init \
		&& $(TF) destroy -auto-approve


.PHONY: bootstrap inception destroy-bootstrap destroy-inception
