GIT_COMMIT=`git log -1 --format=%h .`
VERSION=`git describe --tags --always --dirty`-`git rev-parse --abbrev-ref HEAD`
CONTAINER_NAME=sshd-container

all: build deploy

build:
	docker build --label GIT_COMMIT=${GIT_COMMIT} -t eu.gcr.io/${PROJECT_ID}/${CONTAINER_NAME}:${VERSION} .

deploy:
	docker push eu.gcr.io/${PROJECT_ID}/${CONTAINER_NAME}:${VERSION}
