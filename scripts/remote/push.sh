#!/bin/bash

rsync -azP . distributed-k8s:/home/kubernetes/distributed-k8s/ --exclude=.git --exclude=.idea --exclude=results --exclude=venv
