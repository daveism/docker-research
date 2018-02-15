#!/bin/sh

IMAGE=$1

PORT=$2

docker run -p $PORT:$PORT $IMAGE