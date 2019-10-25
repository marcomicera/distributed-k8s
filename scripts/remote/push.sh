#!/bin/bash

rsync -azP . distributed-k8s:/home/kubernetes/distributed-k8s/ --filter=':- .gitignore' --exclude=.git --exclude=results
