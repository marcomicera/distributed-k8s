# `distributed-k8s`: Kubernetes benchmarking

`distributed-k8s` (a.k.a. `dk8s`) is a benchmarking tool based on Google Cloud Platform's [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) that can periodically run benchmarks as [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) on [Kubernetes](https://kubernetes.io/).
Results can be exposed to a [Prometheus Pushgateway](https://github.com/prometheus/pushgateway).

### Supported benchmarks
- `block_storage_workload`
- `cassandra_ycsb`
- `cassandra_stress`
- `cluster_boot`
- `fio`
- `iperf`
- `mesh_network`
- `mongodb_ycsb`
- `netperf`
- `redis`

# How to run it

Benchmarks are periodically launched as a [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

### Steps

1. Clone this repository:
    ```bash
   $ git clone git@github.com:marcomicera/distributed-k8s.git
   $ cd distributed-k8s
   $ git submodule update --init --recursive
   ```
1. Set the number of pods to be used for each benchmark in the [`dk8s-num-pods.yaml`](dk8s-num-pods.yaml) file and apply the [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/):
    ```bash
    $ kubectl create cm dk8s-num-pods --from-file dk8s-num-pods.yaml -o yaml --dry-run | kubectl replace -f -
    ``` 
1. Create a dedicated [ServiceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/):
    ```bash
    $ ./dk8s-create-sa.sh
    ```
1. Set the [Pushgateway](https://github.com/prometheus/pushgateway) address in [`yaml/base/dk8s-conf.yaml`](yaml/base/dk8s-conf.yaml)
1. Launch a benchmark periodically. E.g., for `iperf`:
    ```bash
    $ kubectl kustomize yaml/benchmarks/iperf | kubectl apply -f -
    ```

### Advanced usage

<details>
<summary>Launch more benchmarks sequentially</summary>
<br>

1. Define the list of benchmarks to run and the [Pushgateway](https://github.com/prometheus/pushgateway) address in [`yaml/base/dk8s-conf.yaml`](yaml/base/dk8s-conf.yaml)
1. Set the frequency with which benchmarks will be run in [`yaml/base/dk8s-pkb-cronjob.yaml`](yaml/base/dk8s-pkb-cronjob.yaml)
    ```yaml
    schedule: '0 * * * *'
    ```
1. Launch this set of benchmarks periodically:
    ```bash
    $ kubectl kustomize yaml/base | kubectl apply -f -
    ```

</details>

<details>
<summary>Preliminary steps to run benchmarks locally</summary>
<br>

1. Start [`minikube`](https://github.com/kubernetes/minikube) on your local machine:
    ```bash
    $ minikube start
    ```
1. Add the current user to the `docker` group:
    ```bash
    $ newgrp docker
    ```

1.  To use a local Docker image:
    1. Run a [local Docker registry](https://docs.docker.com/registry/deploying/):
        ```bash
        $ docker run -d -p 5000:5000 --restart=always --name registry registry:2
        ```
    2. Build the Docker image:
        ```bash
        $ docker build -t dk8s-pkb docker/dk8s-pkb/ && docker tag dk8s-pkb:latest marcomicera/dk8s-pkb
        ```

1. [Run it](#how-to-run-it)

When you're done:
1. Stop the local Docker registry:
    ```bash
    $ docker container stop registry
    ```
1. Remove its container:
    ```bash
    $ docker container rm -v registry
    ```
1. Stop [`minikube`](https://github.com/kubernetes/minikube);
    ```bash
    $ minikube stop
    ```
</details>

# Documentation
Check [`doc/README.md`](doc/README.md) for the complete documentation.

# References
- Google's [`PerfKit Benchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) ([description](https://cloud.google.com/free/docs/measure-compare-performance))
- The [Prometheus](https://prometheus.io/) monitoring system
  - [Grafana](https://grafana.com/) for time series analytics
- [Kubernetes](https://kubernetes.io/docs/reference/)
  - [`minikube`](https://github.com/kubernetes/minikube) (and its [documentation](https://minikube.sigs.k8s.io/docs/))
