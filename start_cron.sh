#!/bin/bash

# Which benchmarks can be run on Kubernetes with PKB
AVAILABLE_BENCHMARKS=(
    block_storage_workload
    cassandra_ycsb
    cassandra_stress
    cluster_boot
    fio
    iperf
    mesh_network
    mongodb_ycsb
    netperf
    redis
)

# Script usage help message
if (( $# < 1 )); then
    printf "Usage: ./start.sh <benchmarks_to_run>\n\nSupported benchmarks on Kubernetes: {\n"
    printf '\t%s\n' "${AVAILABLE_BENCHMARKS[@]}"
    printf "}\n\nOr simply type 'all' to run all of them.\n"
    exit 1
fi
VERBOSE=false

# Letting the main script know that a CronJob must be started
CRONJOB=true
export CRONJOB

# `kubectl` flags
IMAGE=marcomicera/dk8s-cronjob:latest
DRY_RUN=false
KUBECTL_FLAGS=-o=yaml
if [ "$DRY_RUN" = true ] ; then
  KUBECTL_FLAGS+=\ --dry-run
fi

# Check whether to run all benchmarks or not
BENCHMARKS_TO_RUN=()
if [ "$1" == "all" ] ; then
  BENCHMARKS_TO_RUN=("${AVAILABLE_BENCHMARKS[@]}")
else
  BENCHMARKS_TO_RUN=("$@")
fi
echo "About to launch the following benchmarks: ${BENCHMARKS_TO_RUN[@]}"

# Info
if [ "$VERBOSE" = true ] ; then
  echo User wants to run the following benchmarks: "$@"
  for AVAILABLE_BENCHMARK in "${AVAILABLE_BENCHMARKS[@]}"; do
    declare "BENCHMARK_FLAGS=${AVAILABLE_BENCHMARK}_FLAGS"
    echo Using the following flags for "$AVAILABLE_BENCHMARK": "${!BENCHMARK_FLAGS}"
  done
fi

# Starting the CronJob
if [ "$DRY_RUN" = true ] ; then
  printf 'Dry-running the following benchmakrs as a CronJob: {\n'
else
  printf 'Launching the following benchmarks as a CronJob: {\n'
fi
printf '\t%s\n' "${AVAILABLE_BENCHMARKS[@]}"
printf '}\n'
kubectl run $KUBECTL_FLAGS \
  "cron-$(uuidgen | head -c8)" \
  --schedule="*/1 * * * *" \
  --restart=OnFailure \
  --image=$IMAGE \
  -- /bin/sh -c "./start.sh ${AVAILABLE_BENCHMARKS[@]}; /bin/sh"
if [ "$DRY_RUN" = false ] ; then
  echo ...CronJob launched.
fi
