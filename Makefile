.PHONY: build_venv build_docker ensure_image lint_code lint_tests run run_tests test \
	update_dependencies upload_docker venv_activate deploy

DOCKER_IMAGE = 772681551441.dkr.ecr.us-east-1.amazonaws.com/security-token-analytics
KUBE = kubectl --context="arn:aws:eks:us-east-1:772681551441:cluster/insight-prod-cluster"
VERSION = $(shell git rev-parse --short HEAD)
IMAGE_FOUND = $(shell docker images \
			  --format "{{ .Repository }}" --filter "reference=security_token_analytics")
AIRFLOW_TF_CONFIG_DIR = terraform/environments/prod/services/airflow

test: build_venv

#
# Uploads our Docker image to ECR with both latest and version tags.
#
upload_docker: build_docker

	# Tag our image
	docker tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):$(VERSION)

	# Authenticate with ECR and push the image
	eval $(aws ecr get-login --no-include-email) && docker push $(DOCKER_IMAGE):$(VERSION)
	eval $(aws ecr get-login --no-include-email) && docker push $(DOCKER_IMAGE):latest


deploy: upload_docker
	echo "Redeploying the Airflow webserver"
	cd $(AIRFLOW_TF_CONFIG_DIR) && terraform taint --module=airflow kubernetes_deployment.airflow_webserver
	cd $(AIRFLOW_TF_CONFIG_DIR) && terraform plan -target=module.airflow.kubernetes_deployment.airflow_webserver -out=tfplan
	cd $(AIRFLOW_TF_CONFIG_DIR) && terraform apply "tfplan"

	echo "Redeploying the Airflow scheduler"
	cd $(AIRFLOW_TF_CONFIG_DIR) && terraform taint --module=airflow kubernetes_deployment.airflow_scheduler
	cd $(AIRFLOW_TF_CONFIG_DIR) && terraform plan -target=module.airflow.kubernetes_deployment.airflow_scheduler -out=tfplan
	cd $(AIRFLOW_TF_CONFIG_DIR) && terraform apply "tfplan"


venv_activate:
	pipenv shell


update_dependencies:
	pipenv update --dev
	make test


# ==========================
# Internal targets
# ==========================

build_docker:
	docker build --build-arg VERSION=$(VERSION) -t $(DOCKER_IMAGE) .

build_venv:
	pipenv sync --dev

