#!/bin/bash

docker build -t dk8s-cronjob docker/dk8s-cronjob/ && docker tag dk8s-cronjob:latest marcomicera/dk8s-cronjob && docker push marcomicera/dk8s-cronjob
