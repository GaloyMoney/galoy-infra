TF:=terraform

bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) apply

destroy-bootstrap:
	cd bootstrap \
		&& $(TF) init \
		&& $(TF) destroy

<<<<<<< HEAD
.PHONY: bootstrap
=======
inception:
	cd inception \
		&& $(TF) init \
		&& $(TF) apply

destroy-inception:
	cd inception \
		&& $(TF) init \
		&& $(TF) destroy


.PHONY: bootstrap inception

>>>>>>> e911944 (need to fix make inception run)
