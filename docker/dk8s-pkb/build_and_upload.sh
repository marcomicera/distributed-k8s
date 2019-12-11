#!/bin/bash

docker build -t dk8s-pkb docker/dk8s-pkb/ && docker tag dk8s-pkb:latest marcomicera/dk8s-pkb && docker push marcomicera/dk8s-pkb
