# `kubemarks`: KUBErnetes benchMARKS
<p align="center">
    <img alt="GitHub" src="https://img.shields.io/github/license/marcomicera/distributed-k8s">
    <a href="https://github.com/marcomicera/kubemarks/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/marcomicera/kubemarks"></a>
    <img alt="GitHub tag (latest by date)" src="https://img.shields.io/github/v/tag/marcomicera/kubemarks">
</p>

`kubemarks` is a benchmarking tool based on Google Cloud Platform's [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) that can periodically run benchmarks as [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) on [Kubernetes](https://kubernetes.io/).
Results can be exposed to a [Prometheus Pushgateway](https://github.com/prometheus/pushgateway).

### Supported benchmarks
- `block_storage_workload`
- `cluster_boot`
- `fio`
- `iperf`
- `mesh_network`
- `netperf`
<!--
- `cassandra_ycsb`
- `cassandra_stress`
- `mongodb_ycsb`
- `redis`
-->

# How to run it

Benchmarks are periodically launched as a [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/).

### Steps

1. Clone this repository:
    ```bash
   $ git clone git@github.com:marcomicera/kubemarks.git
   $ cd kubemarks
   $ git submodule update --init --recursive
   ```
1. Set the number of pods to be used for each benchmark in the [`yaml/base/kubemarks-num-pods.yaml`](yaml/base/kubemarks-num-pods.yaml) file
1. Set the [Pushgateway](https://github.com/prometheus/pushgateway) address in [`yaml/base/kubemarks-conf.yaml`](yaml/base/kubemarks-conf.yaml)
1. Launch a benchmark periodically. E.g., for `iperf`:
    ```bash
    $ kubectl kustomize yaml/benchmarks/iperf | kubectl apply -f -
    ```

### Launch more benchmarks programmatically

1. Define the list of benchmarks to run (and the [Pushgateway](https://github.com/prometheus/pushgateway) address) in [`yaml/base/kubemarks-conf.yaml`](yaml/base/kubemarks-conf.yaml)
1. Set the number of pods to be used for each benchmark in the [`yaml/base/kubemarks-num-pods.yaml`](yaml/base/kubemarks-num-pods.yaml) file
1. Set the frequency with which benchmarks will be run in [`yaml/base/kubemarks-pkb-cronjob.yaml`](yaml/base/kubemarks-pkb-cronjob.yaml)
    ```yaml
    schedule: '0 * * * *'
    ```
1. Launch this set of benchmarks periodically:
    ```bash
    $ kubectl kustomize yaml/base | kubectl apply -f -
    ```

# Documentation
Check [`doc/README.md`](doc/README.md) for the complete documentation.

# References
- Google's [`PerfKit Benchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) ([description](https://cloud.google.com/free/docs/measure-compare-performance))
- The [Prometheus](https://prometheus.io/) monitoring system
  - [Grafana](https://grafana.com/) for time series analytics
- [Kubernetes](https://kubernetes.io/docs/reference/)
  - [`minikube`](https://github.com/kubernetes/minikube) (and its [documentation](https://minikube.sigs.k8s.io/docs/))
