#!/bin/bash

# Script usage help message
if (( $# < 1 )); then
    echo "Usage: ./start.sh <benchmarks_to_run>"
    exit 1
fi
VERBOSE=false

# PKB repo
PKB_FOLDER=pkb
REPO=git@github.com:marcomicera/PerfKitBenchmarker.git

# Benchmarks config
THREADS=4
IMAGE=ubuntu
RUN_URI=$(uuidgen | head -c8)
PKB_FLAGS=--max_concurrent_threads\ $THREADS\ --image\ $IMAGE\ --run_uri=$RUN_URI
KUBERNETES_FLAGS=--kubectl=$(command -v kubectl)\ --kubeconfig=$HOME/.kube/config\

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

# Benchmark-specific flags configuration file
BENCHMARKS_CONFIG_FILE=benchmarks_conf.yaml

# Command line benchmark-specific flags.
# These flags will override the ones in the configuration file.
# To be used when flag values depend on some other factors and
# cannot be expressed in the YAML configuration file.
block_storage_workload_FLAGS=
cassandra_ycsb_FLAGS=
cassandra_stress_FLAGS=
cluster_boot_FLAGS=
fio_FLAGS=
iperf_FLAGS=
mesh_network_FLAGS=
mongodb_ycsb_FLAGS=
netperf_FLAGS=
redis_FLAGS=--config_override=redis.vm_groups.default.redis_clients=$((THREADS - 1))

# Info
if [ "$VERBOSE" = true ] ; then
  echo User wants to run the following benchmarks: "$@"
  for AVAILABLE_BENCHMARK in "${AVAILABLE_BENCHMARKS[@]}"; do
    declare "BENCHMARK_FLAGS=${AVAILABLE_BENCHMARK}_FLAGS"
    echo Using the following flags for "$AVAILABLE_BENCHMARK": "${!BENCHMARK_FLAGS}"
  done
fi

# Python 2.7 is required by PerfKitBenchmarker
echo Running \'sudo apt install python python-pip -y\'...
sudo apt install python python-pip -y

# Installing PerfKitBenchmarker dependencies
echo Cloning the PerfKitBenchmarker repository...
git clone $REPO $PKB_FOLDER
echo ...repository successfully cloned.
cd $PKB_FOLDER || exit
sudo pip install -r requirements.txt
cd ..

# Running all benchmarks
echo Results will available in /tmp/perfkitbenchmarker/runs/"$RUN_URI"
for BENCHMARK_TO_RUN in "$@"; do
  if [[ " ${AVAILABLE_BENCHMARKS[@]} " =~ ${BENCHMARK_TO_RUN} ]]; then
    declare "BENCHMARK_FLAGS=${BENCHMARK_TO_RUN}_FLAGS"
    echo Running the "$BENCHMARK_TO_RUN" benchmark with the following flags: "${!BENCHMARK_FLAGS}"...
    $PKB_FOLDER/pkb.py $PKB_FLAGS --benchmarks=$BENCHMARK_TO_RUN $KUBERNETES_FLAGS --benchmark_config_file=$BENCHMARKS_CONFIG_FILE $BENCHMARK_FLAGS
    echo ...done with "$BENCHMARK_TO_RUN".
  else
    echo "$BENCHMARK_TO_RUN" is not supported. Skipping it...
  fi
done
