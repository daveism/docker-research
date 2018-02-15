#!/bin/sh

IMAGE_TAG=$1

DKRFILE_DIR=$2

docker build -t $IMAGE_TAG $DKRFILE_DIR