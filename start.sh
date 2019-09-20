#!/bin/bash

. util/config.sh
KUBERNETES_FLAGS=--cloud=Kubernetes\ --kubectl=$(which kubectl)\ --kubeconfig=$HOME/.kube/config\ --kubernetes_anti_affinity=false
IMAGE=ubuntu
BENCHMARKS=fio
THREADS=4

# The image is ready to be used by Perfkit:
$PKB_FOLDER/pkb.py --max_concurrent_threads=$THREADS --image=$IMAGE --benchmarks=$BENCHMARKS $KUBERNETES_FLAGS
