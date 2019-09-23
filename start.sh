#!/bin/bash

# PKB repo
PKB_FOLDER=pkb
REPO=git@github.com:GoogleCloudPlatform/PerfKitBenchmarker.git

# Benchmarks config
THREADS=4
IMAGE=ubuntu
BENCHMARKS=fio

# Benchmark arguments
KUBERNETES_FLAGS=--cloud=Kubernetes\ --kubectl=$(which kubectl)\ --kubeconfig=$HOME/.kube/config\ --kubernetes_anti_affinity=false
REDIS_FLAGS="--redis_clients `expr $THREADS - 1`"

# Installing PerfKit Benchmarker dependencies
git clone $REPO $PKB_FOLDER
cd $PKB_FOLDER
sudo pip install -r requirements.txt
cd ..

# The image is ready to be used by Perfkit
$PKB_FOLDER/pkb.py --max_concurrent_threads=$THREADS --image=$IMAGE --benchmarks=$BENCHMARKS $KUBERNETES_FLAGS # $REDIS_FLAGS
