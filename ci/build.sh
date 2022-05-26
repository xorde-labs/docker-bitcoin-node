#!/bin/sh

COIN_NAME=bitcoin
NODE_NAME=${COIN_NAME}-node
IMAGE_NAME=xorde/${NODE_NAME}

docker build -t ${IMAGE_NAME} .

if [ $? -eq 0 ]
then
	echo ">>> Build successful"
	IMAGE_VERSION=$(docker run ${IMAGE_NAME} ./version.sh)
	docker image tag ${IMAGE_NAME} ${IMAGE_NAME}:${IMAGE_VERSION}
	docker image ls ${IMAGE_NAME}
  	docker push -a ${IMAGE_NAME}
	exit 0
else
  echo ">>> Build failed" >&2
  exit 1
fi
