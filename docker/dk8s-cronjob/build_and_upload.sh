#!/bin/bash

#
# Build and pushes this Dockerfile
#

# Tag
TAG=${1:-latest}

docker build docker/dk8s-cronjob/ -t marcomicera/dk8s-cronjob:$TAG && docker push marcomicera/dk8s-cronjob:$TAG
