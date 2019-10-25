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

# PKB repo
PKB_FOLDER=pkb
REPO=git@github.com:marcomicera/PerfKitBenchmarker.git

# Benchmarks config
CRONJOB=false # when true, creates a cronjob
DRY_RUN=false
THREADS=4
IMAGE=marcomicera/sudobuntu:latest
CURRENT_DATE=$(date '+%Y-%m-%d-%H-%M-%S')
RESULTS_DIR=./results/tmp/$CURRENT_DATE
CSV_RESULTS=$RESULTS_DIR/results.csv
PKB_FLAGS=--max_concurrent_threads\ $THREADS\ --image\ $IMAGE\ --temp_dir\ $RESULTS_DIR\ --csv_path\ $CSV_RESULTS\ --csv_write_mode\ a
KUBECTL_FLAGS=-o\ yaml
if [ "$DRY_RUN" = true ] ; then
  KUBECTL_FLAGS+=\ --dry-run
fi
BENCHMARKS_CONFIG_FILE=benchmarks_conf.yaml
KUBERNETES_FLAGS=--kubectl=$(command -v kubectl)\ --kubeconfig=$HOME/.kube/config\ --benchmark_config_file=$BENCHMARKS_CONFIG_FILE
if [ "$CRONJOB" = true ] ; then
  KUBERNETES_FLAGS+=\ --generator=run-pod/v1
fi

# Check whether to run all benchmarks or not
BENCHMARKS_TO_RUN=()
if [ "$1" == "all" ] ; then
  BENCHMARKS_TO_RUN=("${AVAILABLE_BENCHMARKS[@]}")
else
  BENCHMARKS_TO_RUN=("$@")
fi
echo "About to launch the following benchmarks: ${BENCHMARKS_TO_RUN[@]}"

# Command line benchmark-specific flags.
# These flags will override the ones in the configuration file.
# To be used when flag values depend on some other factors and/or
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

# Cloning Kubernetes scripts gist
git clone git@gist.github.com:4ea9f95c89f15e0f79cd9b2d62ae47cb.git scripts/kube

# Running all benchmarks
for BENCHMARK_TO_RUN in ${BENCHMARKS_TO_RUN[@]}; do
  if [[ " ${AVAILABLE_BENCHMARKS[@]} " =~ ${BENCHMARK_TO_RUN} ]]; then
    declare "BENCHMARK_FLAGS=${BENCHMARK_TO_RUN}_FLAGS"
    if [ "$CRONJOB" = true ] ; then
      echo Launching a "$BENCHMARK_TO_RUN" CronJob with the following flags: "${!BENCHMARK_FLAGS}"...
      kubectl run $KUBECTL_FLAGS "cron-$(sed s/_/-/g <<<"$BENCHMARK_TO_RUN")-$(uuidgen | head -c8)" --schedule="*/1 * * * *" --restart=OnFailure --image=busybox -- /bin/bash -c "$PKB_FOLDER/pkb.py $PKB_FLAGS --benchmarks=$BENCHMARK_TO_RUN $KUBERNETES_FLAGS $BENCHMARK_FLAGS"
      echo ..."$BENCHMARK_TO_RUN" CronJob launched. Results will be stored in $RESULTS_DIR.
    else
      echo Running the "$BENCHMARK_TO_RUN" benchmark with the following flags: "${!BENCHMARK_FLAGS}"...
      $PKB_FOLDER/pkb.py $PKB_FLAGS --benchmarks=$BENCHMARK_TO_RUN $KUBERNETES_FLAGS $BENCHMARK_FLAGS
      echo ...done with "$BENCHMARK_TO_RUN". Results available in $RESULTS_DIR.
    fi
  else
    echo "$BENCHMARK_TO_RUN" is not supported. Skipping it...
  fi
done
