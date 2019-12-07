# Table of Contents

- [1. Introduction](#1-introduction)
- [2. Existing work](#2-existing-work)
- [3. Implementation](#3-implementation)
  * [3.1 Supported benchmarks](#31-supported-benchmarks)
<!-- TODO -->

# 1. Introduction
Running benchmarks on the cloud is not only useful to compare different providers but also to measure the differences in the underlying physical hardware.
[`distributed-k8s`](https://github.com/marcomicera/distributed-k8s) (a.k.a. [`dk8s`](https://github.com/marcomicera/distributed-k8s)) focuses on the latter aspect, specifically on [Kubernetes](https://kubernetes.io/): it can run a varied [list of benchmarks](https://github.com/marcomicera/distributed-k8s#supported-benchmarks) and expose their results to the [Prometheus](https://prometheus.io/) monitoring system.

# 2. Existing work
Adapting existing benchmarks to run on [Kubernetes](https://kubernetes.io/) may not be straight-forward, especially when dealing with distributed ones that, by definition, need to involve multiple pods.
Yet there are [some attempts](https://github.com/jberkus/pgKubernetesTutorial) online that try to do so.
On the other hand, retrieving benchmark results from different pods requires way more work than just adapting them to [Kubernetes](https://kubernetes.io/).

This is where [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) comes into play, an open-source tool by [Google Cloud Platform](https://cloud.google.com/) that contains a set of benchmarks that are ready to be run on several cloud offerings, including [Kubernetes](https://kubernetes.io/).
In short, [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker):
- creates and configures as many [Kubernetes](https://kubernetes.io/) pods as needed by the benchmark,
- handles their lifecycle,
- installs dependencies,
- runs benchmarks,
- retrieves results from all pods and, lastly,
- makes it easy to add additional "results writers" so that results can be exported in different ways.

# 3. Implementation
This section aims to describe some system and implementation details needed to accomplish what has been described in [§1](#1-introduction).

## 3.1 Supported benchmarks
There are four main categories of [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker)-supported benchmarks runnable on [Kubernetes](https://kubernetes.io/):
- I/O-based (e.g., [fio](https://github.com/axboe/fio)),
- database-oriented (e.g., [YCSB](https://github.com/brianfrankcooper/YCSB) on [Cassandra](http://cassandra.apache.org/) and [MongoDB](https://www.mongodb.com/), [memtier_benchmark](https://github.com/RedisLabs/memtier_benchmark) on [Redis](https://redis.io/)),
- networking-oriented (e.g., [iperf](https://github.com/esnet/iperf) and [netperf](https://hewlettpackard.github.io/netperf/)), and
- resource manager-oriented (e.g., measuring VM placement latency and boot time).

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