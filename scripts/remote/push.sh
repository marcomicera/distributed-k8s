#!/bin/bash

#
# Pushes this repo on a target machine
#

# Target machine
HOST=${1:-distributed-k8s}

# Where the repo will be stored remotely
# (with respect to ~)
REMOTE_FOLDER=distributed-k8s

rsync -azvP . $HOST:$REMOTE_FOLDER/ \
  --exclude=.git \
  --exclude=results \
  --exclude=docker \
  --exclude=.idea \
  --exclude=venv \
  --filter=':- pkb/.gitignore'
