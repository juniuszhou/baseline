# Makefile

# relative path to the construction site
radish34=./radish34

# over time, as the radish34 use-case is abstracted/generalized into
# the baseline protocol, the pushd/popd hacks will fade away...

.PHONY: build build-containers clean contracts deploy-contracts npm-install start stop system-check reset restart test zk-circuits

default: build

build: npm-install contracts

build-containers: build
	@pushd ${radish34} && \
	docker-compose build && \
	popd

clean: stop
	@$(radish34)/../bin/clean_npm.sh

contracts:
	@pushd ${radish34} && \
	npm run build:contracts && \
	popd

deploy-contracts:
	@pushd ${radish34} && \
	npm run deploy && \
	popd

npm-install:
	@pushd ${radish34} && \
	npm run build && \
	popd

start: system-check build-containers
	@pushd ${radish34} && \
	docker-compose up -d && \
	npm run setup-circuits && \
	npm run deploy && \
	popd

stop:
	@pushd ${radish34} && \
	docker-compose down && \
	popd

system-check:
	@npm run --silent system-check

reset: stop
	@pushd ${radish34} && \
	docker volume rm \
		radish34_mongo-buyer \
		radish34_mongo-supplier1 \
		radish34_mongo-supplier2 \
		radish34_mongo-merkle-tree-volume \
		radish34_chaindata && \
	docker container prune -f && \
	docker network prune -f && \
	rm -rf ./config && \
	popd

restart: stop start

test:
	@pushd ${radish34} && \
	npm run test && \
	npm run postman-test-zkp-api && \
	npm run postman-integration-test && \
	popd

zk-circuits:
	@pushd ${radish34} && \
	npm run setup-circuits && \
	popd