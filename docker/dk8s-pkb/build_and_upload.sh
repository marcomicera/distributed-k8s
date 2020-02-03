#!/bin/bash

#
# Build and pushes this Dockerfile
#

# Tag
TAG=${1:-latest}

docker build docker/dk8s-pkb/ -t marcomicera/dk8s-pkb:$TAG && docker push marcomicera/dk8s-pkb:$TAG
