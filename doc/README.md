# Table of Contents

- [Introduction](#introduction)
- [Existing work](#existing-work)
- [Implementation](#implementation)
  * [Supported benchmarks](#supported-benchmarks)
  * [PerfKit Benchmarker fork changes](#-perfkit-benchmarker-fork-changes)
    + [Including node IDs in benchmark results](#including-node-ids-in-benchmark-results)
  * [Running benchmarks periodically](#running-benchmarks-periodically)
    + [Docker images](#docker-images)
    + [The base CronJob file](#the-base-cronjob-file)
    + [Dedicated CronJob files for benchmarks](#dedicated-cronjob-files-for-benchmarks)
  * [Permissions](#permissions)
- [Guide](#guide)
  * [Configuration](#configuration)
    + [Number of Kubernetes pods](#number-of-kubernetes-pods)
    + [CronJob frequency](#-cronjob-frequency)
    + [Experiment configuration file](#experiment-configuration-file)
    + [Specifying the kubeconfig file](#specifying-the-kubeconfig-file)
  * [Launching benchmarks](#launching-benchmarks)
- [Conclusions](#conclusions)

# Introduction
Running benchmarks on the cloud is not only useful to compare different providers but also to measure the differences in the underlying physical hardware.
[`distributed-k8s`](https://github.com/marcomicera/distributed-k8s) (a.k.a. [`dk8s`](https://github.com/marcomicera/distributed-k8s)) focuses on the latter aspect, specifically on [Kubernetes](https://kubernetes.io/): it can run a varied [list of benchmarks](https://github.com/marcomicera/distributed-k8s#supported-benchmarks) and expose their results to the [Prometheus](https://prometheus.io/) monitoring system.

# Existing work
Adapting existing benchmarks to run on [Kubernetes](https://kubernetes.io/) may not be straight-forward, especially when dealing with distributed ones that, by definition, need to involve multiple pods.
Yet there are [some attempts online](https://github.com/jberkus/pgKubernetesTutorial) that try to do so.
On the other hand, retrieving benchmark results from different pods requires way more work than just adapting them to [Kubernetes](https://kubernetes.io/).

This is where [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) comes into play, an open-source tool by [Google Cloud Platform](https://cloud.google.com/) that contains a set of benchmarks that are ready to be run on several cloud offerings, including [Kubernetes](https://kubernetes.io/).
In short, [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker):
- creates and configures as many [Kubernetes](https://kubernetes.io/) pods as needed by the benchmark,
- handles their lifecycle,
- installs dependencies,
- runs benchmarks,
- retrieves results from all pods and, lastly,
- makes it easy to add additional "results writers" so that results can be exported in different ways.

# Implementation
This section aims to describe some system and implementation details needed to accomplish what has been described in the [introduction](#introduction).

## Supported benchmarks
There are four main categories of [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker)-supported benchmarks runnable on [Kubernetes](https://kubernetes.io/):
- I/O-based (e.g., [fio](https://github.com/axboe/fio)),
- database-oriented (e.g., [YCSB](https://github.com/brianfrankcooper/YCSB) on [Cassandra](http://cassandra.apache.org/) and [MongoDB](https://www.mongodb.com/), [memtier_benchmark](https://github.com/RedisLabs/memtier_benchmark) on [Redis](https://redis.io/)),
- networking-oriented (e.g., [iperf](https://github.com/esnet/iperf) and [netperf](https://hewlettpackard.github.io/netperf/)), and
- resource manager-oriented (e.g., measuring VM placement latency and boot time).

## [PerfKit Benchmarker fork](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) changes
Besides minor bug fixes, the custom [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) fork has been extended with an additional "results writer", i.e., endpoint to which results are exported at the end of a single benchmark execution.
More specifically, it now includes a [Prometheus](https://prometheus.io/) [Pushgateway](https://github.com/prometheus/pushgateway) exporter, which exposes results according to the [OpenMetrics](https://openmetrics.io/) format.
The [official Prometheus Python client](https://github.com/prometheus/client_python) has been used to implement this result writer.
Furthermore, the CSV writer can now write results in "append" mode, allowing it to gradually add entries to the same CSV file as soon as benchmarks finish.

### Including node IDs in benchmark results
While [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) does include physical node information in benchmark results (e.g., `lscpu` command output), it does not include [Kubernetes](https://kubernetes.io/) node IDs.
This information is essential to make a [comparison between different hardware solutions](#introduction).
Since [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) is [in charge of creating and configuring pods](#existing-work), its source code had to be extended to make pods aware of the node ID they were running on.
To do this, the [Kubernetes](https://kubernetes.io/) _[Downward API](https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/\#the-downward-api)_ comes in handy: it makes it possible to [expose pod and container fields to a running container](https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/\#the-downward-api): here is the JSON snippet which made that possible:

```json
'env': [{
    'name': 'KUBE_NODE',
    'valueFrom': {
        'fieldRef': {
        'fieldPath': 'spec.nodeName'
        }
    }
}]
```

This way, each [Kubernetes](https://kubernetes.io/) pod can retrieve the node ID of the physical machine on which it is running, and [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) can successfully include this information in the results.

## Running benchmarks periodically
Benchmarks are run periodically as a [Kubernetes](https://kubernetes.io/) _[CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)_.
It periodically executes a shell script ([`scripts/pkb/start.sh`](../scripts/pkb/start.sh)) that cycles through all the benchmarks to be executed and, for each one of them, it
1. checks whether it is compatible with [Kubernetes](https://kubernetes.io/), and
1. builds a proper argument list to be passed to [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker).

### Docker images
A [Kubernetes](https://kubernetes.io/) [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) launches periodic jobs in Docker containers.
The base [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) file of this repository [`yaml/base/dk8s-pkb-cronjob.yaml`](../yaml/base/dk8s-pkb-cronjob.yaml) mainly executes [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker), which in turn needs to launch benchmarks in Docker containers so that the [Kubernetes](https://kubernetes.io/) scheduler can allocate those onto pods.
[`marcomicera/dk8s-cronjob`](https://hub.docker.com/r/marcomicera/dk8s-cronjob) and [`marcomicera/dk8s-pkb`](https://hub.docker.com/r/marcomicera/dk8s-pkb) are the Docker images launched by the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) and [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker), respectively.
The latter takes care of resolving most of the dependencies needed by benchmarks so that [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) will not waste any other time doing so.
The former
1. installs the [Kubernetes](https://kubernetes.io/) command-line tool `kubectl`, and
1. downloads [this repository](https://github.com/marcomicera/distributed-k8s), which also contains the previously-mentioned [PerfKit Benchmarker fork](https://github.com/marcomicera/PerfKitBenchmarker) as a git submodule.

### The [base CronJob file](../yaml/base/dk8s-pkb-cronjob.yaml)

### Dedicated CronJob files for benchmarks

<!-- FIXME 
## Passing files to containers
Containers launched by the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) need to find two files in their filesystem: a benchmarks configuration file and a [Kubernetes](https://kubernetes.io/) [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file, both described in \cref{benchmarks_conf} and \cref{kubeconfig}.
This is achieved by creating [Kubernetes](https://kubernetes.io/) [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/) from these two files (\autoref{benchmarks_conf_secret} and \autoref{kubeconfig_secret}).
\autoref{secret_mounting} depicts a code snippet from the \href{https://github.com/marcomicera/distributed-k8s/blob/master/cronjob.yaml}{\texttt{cronjob.yaml}} file that shows how they are mounted in containers' filesystem.

```yaml
kind: CronJob
spec:
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            image: marcomicera/dk8s-cronjob:latest
            volumeMounts:
            - mountPath: /home/root/distributed-k8s/kubeconfig
              name: dk8s-kubeconfig
              readOnly: true
              subPath: kubeconfig
            - mountPath: /home/root/distributed-k8s/benchmarks-conf.yaml
              name: dk8s-benchconfig
              readOnly: true
              subPath: benchmarks-conf.yaml
          volumes:
          - name: dk8s-kubeconfig
            secret:
              secretName: dk8s-kubeconfig
          - name: dk8s-benchconfig
            secret:
              secretName: dk8s-benchconfig
```
-->

## Permissions
<!-- ServiceAccount, kubeconfig, Role, RoleBinding -->

# Guide
This guide refers to the \href{https://github.com/marcomicera/distributed-k8s}{github.com/marcomicera/distributed-k8s} repository, clonable with the following command:

```bash
$ git clone git@github.com:marcomicera/distributed-k8s.git
$ cd distributed-k8s
```

## Configuration
This section describes all configuration steps to be made before launching benchmarks.

### Number of [Kubernetes](https://kubernetes.io/) pods
The number of [Kubernetes](https://kubernetes.io/) pods to be used for every benchmark is defined in the \href{https://github.com/marcomicera/distributed-k8s/blob/master/benchmarks-conf.yaml}{\texttt{{\justify}benchmarks-conf.yaml}} configuration file.

```yaml
flags:
  cloud: Kubernetes
  kubernetes_anti_affinity: false

block_storage_workload:
  description: >
    Runs FIO in sequential, random, read and
    write modes to simulate various scenarios.
  vm_groups:
    default:
      vm_count: 1
```

It is worth noticing that [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) uses the term \textit{VM} as a generalization of \textit{[Kubernetes](https://kubernetes.io/) pod} since it supports multiple cloud providers.

Finally, the user needs to create a [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/secret/}{Secret} from this file.

```bash
$ kubectl create secret generic dk8s-benchconfig --from-file=benchmarks-conf.yaml
```

This will make this file available to the container running [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker).

### [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) frequency
Next, the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) frequency can be adjusted in the \href{https://github.com/marcomicera/distributed-k8s/blob/master/cronjob.yaml}{\texttt{cronjob.yaml}} file:

```yaml
schedule: '*/30 * * * *'
```

The schedule follows the \href{https://en.wikipedia.org/wiki/Cron}{Cron} format\footnote{\href{https://en.wikipedia.org/wiki/Cron}{en.wikipedia.org/wiki/Cron}}.

### Experiment configuration file
The \href{https://github.com/marcomicera/distributed-k8s/blob/master/experiment-conf.yaml}{\texttt{experiment-conf.yaml}} file contains two experiment options, namely
\begin{mylist}
    \item the [Prometheus](https://prometheus.io/) [Pushgateway](https://github.com/prometheus/pushgateway) address, and
    \item the list of benchmarks to run
\end{mylist}.

```yaml
apiVersion: v1
data:
  benchmarks: cluster_boot fio
  pushgateway: pushgateway.address.test
kind: ConfigMap
```

Experiments can be chosen amongst this list:
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

Finally, the user must apply the [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/):

```bash
$ kubectl apply -f experiment-conf.yaml
```

### Specifying the [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file
Similarly to \cref{benchmarks_conf}, also the [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/}{kubeconfig} file needs to be passed to containers as a [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/secret/}{Secret}:

```bash
$ kubectl create secret generic dk8s-kubeconfig --from-file=<kubeconfig_path>
```

## Launching benchmarks
It is enough to launch the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) with:

```bash
$ kubectl apply -f cronjob.yaml
```

# Conclusions
The resulting benchmarking tool\footnote{\href{https://github.com/marcomicera/distributed-k8s}{github.com/marcomicera/distributed-k8s}} allows users to periodically (\cref{periodic_benchmarks}) run various kinds of benchmarks (\cref{supported_benchmarks}) on a [Kubernetes](https://kubernetes.io/) cluster.
The custom [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) fork\footnote{\href{https://github.com/marcomicera/PerfKitBenchmarker}{github.com/marcomicera/PerfKitBenchmarker}} (\cref{custom_pkb}) includes physical node identifiers into benchmark results (\cref{node_id}) and gradually exposes them to a [Prometheus](https://prometheus.io/) [Pushgateway](https://github.com/prometheus/pushgateway) following the [OpenMetrics](https://openmetrics.io/) format.
The tool is configurable through a few handy configuration files (\cref{configuration}).

<!-- FIXME

<details>
<summary>Architecture</summary>
<br>

Periodic benchmarks are launched by means of the [`dk8s-pkb-cronjob.yaml`](dk8s-pkb-cronjob.yaml) file: it runs the [`scripts/pkb/start.sh`](scripts/pkb/start.sh) script inside pods to run [`PerfKit Benchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker).
The [`dk8s-pkb-cronjob.yaml`](dk8s-pkb-cronjob.yaml) file has been generated with the [`start_cron.sh`](start_cron.sh) script.

Here is a description of these two script files:

1. `scripts/pkb/start.sh $BENCHMARKS` launches [`PerfKit Benchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) once:
    - What [`PerfKit Benchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) does:
        1. It creates pods using the `dk8s-pkb` image
        1. It executes benchmarks into these pods
        1. It retrieves results from all pods
        1. It exports results using different publishers (e.g., on `stdout`, CSV file, etc.)
    - It is executed:
        - Locally, if launched by the [`scripts/pkb/start.sh`](scripts/pkb/start.sh) script
        - Using the `dk8s-cronjob` image, if launched periodically (see next point)
    - What does the `dk8s-pkb` image do:
        1. Installs dependencies
        1. Launches benchmarks

1.  `./start_cron.sh $BENCHMARKS` launches benchmarks periodically
    - How it works
        1. It runs [`PerfKit Benchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) in a CronJob, using the `dk8s-cronjob` image
            ```bash
            kubectl run --image=dk8s-cronjob -- /bin/sh -c "scripts/pkb/start.sh $BENCHMARKS"
            ```
    - What does the `dk8s-cronjob` image do:
        1. It simply downloads this repo
            ```docker
            RUN git clone git@github.com:marcomicera/distributed-k8s.git
            ```

</details>

-->