# Table of Contents

- [Introduction](#introduction)
- [Existing work](#existing-work)
- [Implementation](#implementation)
  * [Supported benchmarks](#supported-benchmarks)
  * [PerfKit Benchmarker fork changes](#-perfkit-benchmarker-fork-changes)
    + [Including node IDs in benchmark results](#including-node-ids-in-benchmark-results)
  * [Running benchmarks periodically](#running-benchmarks-periodically)
    + [Docker images](#docker-images)
    + [CronJob files and their structure](#cronjob-files-and-their-structure)
      - [The base CronJob file running an user-defined benchmarks list](#the-base-cronjob-file-running-an-user-defined-benchmarks-list)
      - [Dedicated CronJob files for benchmarks](#dedicated-cronjob-files-for-benchmarks)
  * [Permissions](#permissions)
- [Guide](#guide)
  * [Configuration](#configuration)
    + [Number of Kubernetes pods](#number-of-kubernetes-pods)
    + [CronJob frequency](#-cronjob-frequency)
    + [Benchmarks list and Pushgateway address](#benchmarks-list-and-pushgateway-address)
  * [Launching benchmarks](#launching-benchmarks)
- [Conclusions](#conclusions)

# Introduction
Running benchmarks on the cloud is not only useful to compare different providers but also to measure the differences when changing the  operating conditions of the cluster (e.g., updating the underlying physical hardware, replacing the CNI provider, adding more nodes, running different workloads in background, etc.).
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

### [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) files and their structure
[Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/) is a tool included in `kubectl` that allows users to customize [Kubernetes](https://kubernetes.io/) objects. In this project, it is mainly used to:
1. combine multiple objects in the right order of declaration into a single YAML file, and
1. enable object inheritance.

Objects combination is particularly useful when creating the [base CronJob file that runs an user-defined list of benchmarks](#the-base-cronjob-file-running-an-user-defined-benchmarks-list), while inheritance makes it possible to create [dedicated CronJob files for single benchmarks](#dedicated-cronjob-files-for-benchmarks), making it simpler for the user to launch single benchmarks.

#### The [base CronJob file](../yaml/base/dk8s-pkb-cronjob.yaml) running an user-defined benchmarks list
[Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/) needs a [kustomization](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/glossary.md#kustomization) file as a starting point.
The [base `kustomization.yaml` file](../yaml/base/kustomization.yaml) simply lists all the [Kubernetes](https://kubernetes.io/) objects needed to launch [`dk8s`](https://github.com/marcomicera/distributed-k8s):

```yaml
resources:
  - dk8s-conf.yaml # benchmarks list, pushgateway address
  - dk8s-role.yaml # PerfKit Benchmarker permissions
  - dk8s-role-binding.yaml # associating Role to ServiceAccount
  - dk8s-pkb-cronjob.yaml # PerfKit Benchmarker base CronJob file
```

All these files can be combined together and applied with a single command:

```bash
$ kubectl kustomize yaml/base | kubectl apply -f -
```

Before launching this command, [`yaml/base/dk8s-conf.yaml`](../yaml/base/dk8s-conf.yaml) and [`yaml/base/dk8s-pkb-cronjob.yaml`](../yaml/base/dk8s-pkb-cronjob.yaml) should be modified accordingly, as described in the [Guide section](#guide).

#### Dedicated CronJob files for benchmarks
When launching single benchmarks, [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/) can be used to override some [Kubernetes](https://kubernetes.io/) object fields of the [base CronJob file](../yaml/base/dk8s-pkb-cronjob.yaml).
Looking at a benchmark-specific [kustomization](https://github.com/kubernetes-sigs/kustomize/blob/master/docs/glossary.md#kustomization) file is enough to determine which fields are actually overridden.
The following [`kustomization.yaml`](../yaml/benchmarks/fio/kustomization.yaml) file depicts all changes needed to run the [fio](../yaml/benchmarks/fio) benchmark:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
bases:
- ../../base
nameSuffix: -fio
patchesStrategicMerge:
  - benchmarks-list.yaml
  - schedule.yaml
```

This file inherits all [Kubernetes](https://kubernetes.io/) objects of the [base `kustomization.yaml` file](../yaml/base/kustomization.yaml), and:
- adds a metadata-name suffix to all its [Kubernetes](https://kubernetes.io/) objects (i.e., `-fio`),
- defines the list of benchmarks to be executed (a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) in [`yaml/benchmarks/fio/benchmarks-list.yaml`](../yaml/benchmarks/fio/benchmarks-list.yaml) containing only `fio` in the list) and,
- overrides the frequency with which this benchmark is run (based on its average completion time).

## Permissions
In the following [Guide section](#guide), the user is asked to run the [`dk8s-create-sa.sh`](../dk8s-create-sa.sh) script before launching [`dk8s`](https://github.com/marcomicera/distributed-k8s).
It is based on an [external gist imported as a git submodule](https://gist.github.com/marcomicera/ba340e9478e1c0c716313971cc3e2e95/3d62b107b41706dbf422a7ac62c01ea4d22ead9b).
In short, it:
1. creates a [ServiceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) in the current namespace,
1. creates a corresponding [kubeconfig](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) file and,
1. creates a secret from it.

When [combining base Kubernetes objects in order to launch a custom list of benchmarks](#the-base-cronjob-file-running-an-user-defined-benchmarks-list), a proper [Role and RoleBinding object](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) are included in the final YAML file, so that the previously-created [ServiceAccount](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) can be used.

# Guide
This section explains the [How to run it section](../README.md#how-to-run-it) of the [main `README.md` file](../README.md) in a more detailed manner.

## Configuration
This section describes all configuration steps to be made before launching benchmarks.

### Number of [Kubernetes](https://kubernetes.io/) pods
The number of [Kubernetes](https://kubernetes.io/) pods to be used for every benchmark is defined in the [`dk8s-num-pods.yaml`](../dk8s-num-pods.yaml) configuration file. Here is an extract:

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

It is worth noticing that [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) uses the term _VM_ as a generalization of _[Kubernetes](https://kubernetes.io/) pod_ since it supports multiple cloud providers.

Finally, the user needs to create a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) from this file.

```bash
$ kubectl create cm dk8s-num-pods --from-file dk8s-num-pods.yaml -o yaml --dry-run | kubectl replace -f -
```

This will then be mounted as a file in the container running [PerfKit Benchmarker](https://github.com/marcomicera/PerfKitBenchmarker).

### [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) frequency
Next, the general [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) frequency can be adjusted in the [`yaml/base/dk8s-pkb-cronjob.yaml`](../yaml/base/dk8s-pkb-cronjob.yaml) file:

```yaml
schedule: '*/30 * * * *'
```

The schedule follows the [Cron](https://en.wikipedia.org/wiki/Cron) format.
There is no need to specify this for the [one-benchmark-only CronJob files](#dedicated-cronjob-files-for-benchmarks), as the frequency will be automatically set by [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/).

### Benchmarks list and [Pushgateway](https://github.com/prometheus/pushgateway) address
The [`yaml/base/dk8s-conf.yaml`](../yaml/base/dk8s-conf.yaml) file contains two experiment options, namely
- the [Prometheus](https://prometheus.io/) [Pushgateway](https://github.com/prometheus/pushgateway) address, and
- the list of benchmarks to run.

```yaml
# `kubectl kustomize yaml/base | kubectl apply -f -` will
# automatically update this ConfigMap
apiVersion: v1
data:
  benchmarks: cluster_boot fio
  pushgateway: pushgateway.address.test
kind: ConfigMap
metadata:
  name: dk8s-conf
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

This [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/) will be automatically applied/updated by [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/).

## Launching benchmarks
Benchmarks can be either launched singularly with (e.g., for [iperf](https://github.com/esnet/iperf)):

```bash
$ kubectl kustomize yaml/benchmarks/iperf | kubectl apply -f -
```

or sequentially, after [having updated the list of benchmarks to run](#benchmarks-list-and-pushgateway-address):

```bash
$ kubectl kustomize yaml/base | kubectl apply -f -
```

# Conclusions
[`dk8s`](https://github.com/marcomicera/distributed-k8s) is able to [periodically](#running-benchmarks-periodically) run [various kinds](#supported-benchmarks) of benchmarks on a [Kubernetes](https://kubernetes.io/) cluster.
The custom [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) fork (more details [here](#-perfkit-benchmarker-fork-changes)) includes [physical node identifiers into benchmark results](#including-node-ids-in-benchmark-results) and gradually exposes them to a [Prometheus](https://prometheus.io/) [Pushgateway](https://github.com/prometheus/pushgateway) following the [OpenMetrics](https://openmetrics.io/) format.
The tool is configurable through a few handy [configuration files](#configuration).
