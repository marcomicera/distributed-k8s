#!/bin/bash

rsync -azP . distributed-k8s:/home/kubernetes/distributed-k8s/ \
  --exclude=.git \
  --exclude=results \
  --exclude=docker \
  --exclude=.idea \
  --exclude=venv \
  --exclude=pkb/.tox
