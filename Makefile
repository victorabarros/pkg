.DEFAULT_GOAL := help
.PHONY: help

APP_NAME?=$(shell pwd | xargs basename)
APP_DIR = /go/src/github.com/victorabarros/${APP_NAME}
DOCKER_BASE_IMAGE=golang:1.14
PROJECT_FILES=$(shell find . -type f -name '*.go' -not -path "./vendor/*")

clean-up:
ifneq ($(shell docker ps --filter "name=${APP_NAME}" -aq 2> /dev/null | wc -l | bc), 0)
	@echo "\e[1m\033[33mRemoving containers\e[0m"
	@docker ps --filter "name=${APP_NAME}" -aq | xargs docker rm -f
endif

debug: clean-up
	@echo "\e[1m\033[33mDebug mode\e[0m"
	@docker run --rm -it -v $(shell pwd):${APP_DIR} -w ${APP_DIR} \
		--name ${APP_NAME}-debug ${DOCKER_BASE_IMAGE} bash

format:
	@clear && make clean-up
	@echo "\e[1m\033[33mFormating\e[0m"
	@docker run --rm -it -v $(shell pwd):${APP_DIR} -w ${APP_DIR} \
		--name ${APP_NAME}-format ${DOCKER_BASE_IMAGE} sh -c " \
			command -v goimports >/dev/null 2>&1 || go get -u golang.org/x/tools/cmd/goimports && \
			goimports -l -w -d ${PROJECT_FILES} && \
			gofmt -l -s -w ${PROJECT_FILES}"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep ^help -v | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

lint:
	@echo "\e[1m\033[33mLint scan with GolangCI-Lint\e[0m"
	@docker run --rm -v ${PWD}:${APP_DIR} -w ${APP_DIR} golangci/golangci-lint:v1.24.0 golangci-lint run -v
	@echo "\ndone"

test:
	@echo "\e[1m\033[33mInitalizing tests\e[0m"
	@docker run --rm -v $(shell pwd):${APP_DIR} -w ${APP_DIR} \
		--name ${APP_NAME}-test ${DOCKER_BASE_IMAGE} \
		sh -c "go test ./... -v -cover -race -coverprofile=./dev/c.out"

test-coverage:
	@echo "\e[1m\033[33mBuilding ./dev/c.out\e[0m"
	@rm -rf ./dev/c.out
	@make test
	@go tool cover -html=./dev/c.out

test-log:
	@echo "\e[1m\033[33mWriting ./dev/tests.log\e[0m"
	@rm -rf dev/tests*.log
	@make test > dev/tests.log
	@echo "\e[1m\033[33mWriting ./dev/tests-summ.log\e[0m"
	@cat dev/tests.log  | grep "coverage: " > dev/tests-summ.log

vendor:
	@echo "\e[1m\033[33mBuilding ./vendor/\e[0m"
	@docker run --rm -v ${PWD}:${APP_DIR} -w ${APP_DIR} \
		--name ${APP_NAME}-vendor ${DOCKER_BASE_IMAGE} go mod vendor
