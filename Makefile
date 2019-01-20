.PHONY: build_venv build_docker ensure_image lint_code lint_tests run run_tests test \
	update_dependencies upload_docker venv_activate

DOCKER_IMAGE = 772681551441.dkr.ecr.us-east-1.amazonaws.com/security-token-analytics
VERSION = $(shell git rev-parse --short HEAD)
IMAGE_FOUND = $(shell docker images \
			  --format "{{ .Repository }}" --filter "reference=security_token_analytics")

test: build_venv

#
# Uploads our Docker image to ECR with both latest and version tags.
#
upload_docker: build_docker

    # Tag our image
	docker tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):$(VERSION)

	# Authenticate with ECR
	eval $(aws ecr get-login --no-include-email)

	# Push to ECR
	docker push $(DOCKER_IMAGE):$(VERSION)
	docker push $(DOCKER_IMAGE):latest

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

