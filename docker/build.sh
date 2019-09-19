#!/bin/bash

IMAGE=$SLAVE_FOLDER/ubuntu_ssh.tar.gz

# Building the docker image
docker build -t=ubuntu_ssh --force-rm=true docker

# Save the image
docker save -o=$IMAGE ubuntu_ssh

# Copy it to each of the slave nodes
# scp $IMAGE file to each of slave nodes

# Load the image on each of the slave nodes
docker load -i=$IMAGE
