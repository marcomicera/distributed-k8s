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
KUBECONFIG=kubeconfig
IMAGE=marcomicera/dk8s-cronjob:latest
DRY_RUN=false
GENERATE_DEPLOYMENT_FILE=true
DRY_RUN_OUTPUT=cronjob.yaml
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
OUTPUT_FD=1
if [ "$DRY_RUN" = true ] ; then
  printf 'Dry-running the following benchmakrs as a CronJob: {\n'
else
  printf 'Launching the following benchmarks as a CronJob: {\n'
fi
printf '\t%s\n' "${BENCHMARKS_TO_RUN[@]}"
printf '}\n'
if [ "$GENERATE_DEPLOYMENT_FILE" = true ] ; then
  printf "Deployment file: %s\n" $DRY_RUN_OUTPUT
  OUTPUT_FD=$DRY_RUN_OUTPUT
fi
CONTAINER_NAME="cron-$(uuidgen | head -c8)"
OVERRIDES=$(cat <<EOF
{
  "spec": {
    "jobTemplate": {
      "spec": {
        "template": {
          "spec": {
            "containers": [{
              "name": "$CONTAINER_NAME",
              "image": "$IMAGE",
              "volumeMounts": [{
                "name": "dk8s-kubeconfig",
                "mountPath": "/home/root/distributed-k8s/kubeconfig",
                "readOnly": true,
                "subPath": "kubeconfig"
              }],
              "args": [
                "/bin/sh",
                "-c",
                "./start.sh ${BENCHMARKS_TO_RUN[@]}; /bin/sh"
              ]
            }],
            "volumes": [{
              "name": "dk8s-kubeconfig",
              "secret": {
                "secretName": "dk8s-kubeconfig"
              }
            }],
            "serviceAccountName": "dk8s-sa",
            "dnsPolicy": "Default"
          }
        }
      }
    }
  }
}
EOF
)
kubectl run $KUBECTL_FLAGS \
  $CONTAINER_NAME \
  --schedule="*/1 * * * *" \
  --restart=OnFailure \
  --image-pull-policy Always \
  --image=$IMAGE \
  --kubeconfig=$KUBECONFIG \
  --overrides="$OVERRIDES" >& "$OUTPUT_FD"
if [ "$GENERATE_DEPLOYMENT_FILE" = true ] ; then
  # Hack: delete deployment file's first line (it contains a warning)
  tail -n +2 "$DRY_RUN_OUTPUT" > "$DRY_RUN_OUTPUT.tmp" && mv "$DRY_RUN_OUTPUT.tmp" "$DRY_RUN_OUTPUT"
fi
if [ "$DRY_RUN" = false ] ; then
  echo ...CronJob launched.
fi
