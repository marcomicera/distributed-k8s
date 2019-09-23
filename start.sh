#!/bin/bash

. util/config.sh
THREADS=4
IMAGE=ubuntu
BENCHMARKS=redis

KUBERNETES_FLAGS=--cloud=Kubernetes\ --kubectl=$(which kubectl)\ --kubeconfig=$HOME/.kube/config\ --kubernetes_anti_affinity=false
REDIS_FLAGS="--redis_clients `expr $THREADS - 1`"

# The image is ready to be used by Perfkit:
$PKB_FOLDER/pkb.py --max_concurrent_threads=$THREADS --image=$IMAGE --benchmarks=$BENCHMARKS $KUBERNETES_FLAGS $REDIS_FLAGS
