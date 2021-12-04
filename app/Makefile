CR_NAME		?= ghcr.io
CR_USER		?= takekazuomi
IMAGE_NAME	?= $(CR_NAME)/$(CR_USER)/container-apps05
TAG		?= 0.0.2

help:		## Show this help.
	@sed -ne '/@sed/!s/## //p' $(MAKEFILE_LIST)

run:		## Run
	go run main.go

up: build	## Run in docker
	docker run --rm -it -p 8088:8088 $(IMAGE_NAME):$(TAG)

test:		## Test
	go test takekazu.omi/golang-gin01 -v

cover:		## Coverage
	go test -cover takekazu.omi/golang-gin01

build:		## build docker image
	cd .. && \
	docker build \
		-t $(IMAGE_NAME):$(TAG) \
		-t $(IMAGE_NAME):latest \
		-f ./app/Dockerfile .

push:		## push to container registry
push:	build
	docker push $(IMAGE_NAME):$(TAG)
	docker push $(IMAGE_NAME):latest

ghcr-login:	## login github container registry
	echo $${CR_PAT} | docker login ghcr.io -u $(CR_USER) --password-stdin

login:		## login docker shell
	docker run -it --rm -u=$$(id -u):$$(id -g) -v $(PWD):/workspace $(IMAGE_NAME):latest /bin/sh

curl:		## test from curl
	curl -v -X GET -d "1223" http://localhost:8088/dump
