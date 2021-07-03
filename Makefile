# Copyright IBM Corp All Rights Reserved.
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# -------------------------------------------------------------
# This makefile defines the following targets
#
#   - all (default) - performs code formatting and builds the code
#   - fmt - format code
#   - bsa_example - builds bsa_example as an executable
#   - test - performs tests
#   - lint - runs code analysis tools
#   - clean - cleans the build directories

COMPONENT := $(shell basename $(shell pwd))
IMAGE := ${REGISTRY}/${COMPONENT}:${IMAGE_TAG}

.PHONY: all				##perform code formatting and builds the code
all: fmt build

.PHONY: fmt				##format code
fmt:
	@gci -w .
	@go fmt ./...
	@gofumpt -w .

.PHONY: build		##build the controller
build:
	@go build -o bin/${COMPONENT} cmd/manager/main.go

.PHONY: build-images			##builds docker image locally for running the components using docker
build-images: all
	docker build -t ${IMAGE} --build-arg COMPONENT=${COMPONENT} -f build/Dockerfile .

.PHONY: push-images			##pushes the local docker image to 'docker.io' docker registry
push-images: build-images
	@docker push ${IMAGE}

.PHONY: clean			##clean the build directories
clean:
	@rm -rf bin

.PHONY: lint				##runs code analysis tools
lint:
	go vet ./...
	golangci-lint run ./...

.PHONY: help				##show this help message
help:
	@echo "usage: make [target]\n"; echo "options:"; \fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | sed 's/.PHONY:*//' | sed -e 's/^/  /'; echo "";
