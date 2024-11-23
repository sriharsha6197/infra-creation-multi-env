dev:
	terraform init --backend-config=dev-env/state.tfvars
	terraform plan --var-file=dev-env/input.tfvars
	terraform apply --auto-approve --var-file=dev-env/input.tfvars
dev-destroy:
	terraform destroy --auto-approve --var-file=dev-env/input.tfvars