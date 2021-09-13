#
# Makefile for machine-recipes
#
IMAGE_NAME=tamino-webapp
VERSION=$(shell cat .version)
AWS_DEFAULT_REGION=us-east-1
VERSION=0.1
RESOURCE_GROUP=timba

default: tf-infra
all: build run

# Run tests
test: 
	docker exec -it \
		-e PYTEST_CURRENT_TEST=1 \
		tamino-webapp \
		/usr/local/bin/pytest /src/app/tests

# Get the final status of a deployed stack
get_stack_reason:
	docker run -it --rm \
		-v $(shell pwd):/tmp\
		ktruckenmiller/aws-cli \
		cloudformation describe-stack-events \
		--stack-name $(stack) \
		--region us-east-1 |\
		grep Reason

tf-infra:
	cd ./terraform-infrastructure &&  terraform init
	cd ./terraform-infrastructure &&  terraform apply \
		-auto-approve \
	    -var app-version=${VERSION} \
		-var app-resource-group=${RESOURCE_GROUP}
	terraform output -json

tf-app:
	cd ./terraform-app && terraform init 
	cd ./terraform-app && terraform apply \
		-auto-approve \
	    -var app-version=${VERSION} \
		-var app-resource-group=${RESOURCE_GROUP}
	terraform output -json


# Deploy stacks in deployment
deploy:
	docker run -it --rm \
	 	-v $(shell pwd):/tmp \
		ktruckenmiller/aws-cli  \
		cloudformation deploy \
		--name tamino-webapp \
		--template-file /tmp/deployment/tamino-data-store.yaml \
		--stack-name tamino-data-store \
		--region us-east-1 \
		--parameter-overrides Environment=qa \
		--capabilities CAPABILITY_NAMED_IAM

	make get_stack_reason stack=tamino-data-store

	docker run -v $(shell pwd):/tmp  \
		-it \
		--rm ktruckenmiller/aws-cli  \
		cloudformation deploy \
		--template-file /tmp/deployment/tamino-ecs-environment.yaml \
		--stack-name tamino-ecs \
		--region us-east-1 \
		--parameter-overrides Environment=tools \
		--capabilities CAPABILITY_NAMED_IAM
	
	make get_stack_reason stack=tamino-ecs

# Run development environment
develop:
	mkdir -p build
	docker build --target dev -t $(IMAGE_NAME):$(VERSION) .
	chmod +x docker-entrypoint.sh
	docker run -it --rm \
		-p 4900:80 \
		-p 3000:3000 \
		-v $(shell pwd):/src \
		-e ENVIRONMENT=qa \
		-e BUILDING=518 \
		--name tamino-webapp \
		$(IMAGE_NAME):$(VERSION)

.PHONY: default all test pushs3 deploy develop
