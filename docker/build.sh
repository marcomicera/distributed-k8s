#!/bin/bash

IMAGE_ARCHIVE=$SLAVE_FOLDER/$IMAGE.tar.gz

# Building the docker image
docker build -t=$IMAGE --force-rm=true docker

# Save the image
docker save -o=$IMAGE_ARCHIVE $IMAGE

# Copy it to each of the slave nodes
# scp $IMAGE_ARCHIVE file to each of slave nodes

# Load the image on each of the slave nodes
docker load -i=$IMAGE_ARCHIVE
