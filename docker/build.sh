#!/bin/bash

# Building the docker image
docker build -t=ubuntu_ssh --force-rm=true docker

# Save the imag
docker save -o=ubuntu_ssh.tar.gz ubuntu_ssh

# Copy it to each of the slave nodes
# scp ubuntu_ssh.tar.gz file to each of slave nodes

# Load the image on each of the slave nodes
# docker load -i=ubuntu_ssh.tar.gz

# The image is ready to be used by Perfkit:
# ./pkb.py --image=ubuntu_ssh ...
