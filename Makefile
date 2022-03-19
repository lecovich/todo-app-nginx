APP=$(shell basename $(CURDIR))

DOCKER_HUB_USER = lecovich
REGISTRY ?= $(DOCKER_HUB_USER)/$(APP)
REVISION ?= $(shell git rev-parse --short=8 HEAD)
VERSION ?= $(shell git rev-parse --abbrev-ref HEAD)
BUILDTIME = $(shell date -u +"%Y%m%d%H%M%S")

## -
## Docker commands:

##   docker/login - login to Docker Hub
.PHONY: docker/login
docker/login:
	@echo "Logging in"
	docker login -u $(DOCKER_HUB_USER)

##   docker/image/build - build an image
.PHONY: docker/image/build
docker/image/build:
	@echo "Building docker image"
	docker build \
	    --no-cache \
		--build-arg REVISION=$(REVISION) \
		--build-arg BUILDTIME=$(BUILDTIME) \
		-t $(REGISTRY):$(VERSION) \
		-t $(REGISTRY):$(REVISION) .

##   docker/testconfig - test an NGINX configuration
.PHONY: docker/testconfig
docker/testconfig:
	@echo "Testing configuration"
	docker run --rm \
		-v $(PWD)/nginx:/etc/nginx \
		-p 80:80 \
		$(REGISTRY):$(VERSION) nginx -t

## -
## help - this message
.PHONY: help
help: Makefile
	@echo "Application: ${APP}\n"
	@echo "Run command:\n  make <target>\n"
	@grep -E -h '^## .*' $(MAKEFILE_LIST) | sed -n 's/^##//p'  | column -t -s '-' |  sed -e 's/^/ /'