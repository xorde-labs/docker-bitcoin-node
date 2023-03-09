#!/bin/sh

COIN_NAME=bitcoin
NODE_NAME=${COIN_NAME}-node

export COIN_NAME
export NODE_NAME

docker build --no-cache -t xorde/${NODE_NAME} --build-arg arg-coin-name=${COIN_NAME} --build-arg arg-node-name=${NODE_NAME} .

if [ $? -eq 0 ]
then
	echo ">>> The script ran ok"
  	docker push xorde/${NODE_NAME}
	exit 0
else
  echo ">>> The script failed" >&2
  exit 1
fi
