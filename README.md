# `distributed-k8s`

### [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker)-supported benchmarks runnable in Kubernetes
Set difference between the [Kubernetes-compatible benchmark list](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/benchmark_sets.py#L177) and its [updated unsupported set](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/providers/kubernetes/provider_info.py#L29).
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

<details>
<summary>Comparison table</summary>
<br>

|                              | Distributed                        | File I/O                        | CPU performance               | Memory utilization | Avg. queue length | Scheduler successfulness                     | Useful busy time                   |
|------------------------------|------------------------------|---------------------------------|-------------------------------|--------------------|-------------------|----------------------------------------------|------------------------------------|
|                              | <sub><sup>Requires the cooperation of multiple nodes</sup></sub> | <sub><sup>Requests per second, throughput</sup></sub> | <sup><sub>Task completion time, latency</sup></sub> |                    | <sup><sub>Workload stats</sup></sub>    | <sup><sub># successful allocations / total allocations</sup></sub> | <sup><sub>Time spent scheduling / total time</sup></sub> |
| `block_storage_workload`<br><sub><sup>a.k.a. [`fio`](https://fio.readthedocs.io/en/latest/fio_doc.html)</sup></sub><br>([results](results/local/block_storage_workload/pkb.log), [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/block_storage_workloads_benchmark.py#L15)) | no | yes<sup>([sw](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/block_storage_workload/pkb.log#L5964),[rr](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/block_storage_workload/pkb.log#L5988),[sr](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/block_storage_workload/pkb.log#L6012))</sup> | [yes](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/block_storage_workload/pkb.log#L6037) | [yes](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/block_storage_workload/pkb.log#L5964)<sup>`filesize`</sup> | no | no | no |
| `cassandra_ycsb` <br><sub><sup>Yahoo! Cloud Serving Benchmark</sup></sub><br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/cassandra_ycsb_benchmark.py#L15))     |   |   |   |   |   |   |   |
| `cassandra_stress` <br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/cassandra_stress_benchmark.py#L15))   |   |   |   |   |   |   |   |
| `cluster_boot`<br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/cluster_boot_benchmark.py#L14))               | [no](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/cluster_boot_benchmark.py#L65) |   |   |   |   |   |   |
| [`fio`](https://fio.readthedocs.io/en/latest/fio_doc.html)<br>([results](results/local/fio/pkb.log), [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/fio_benchmark.py#L15))                        | no | yes<sup>([sw](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/fio/pkb.log#L8348),[sr](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/fio/pkb.log#L8372),[rw](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/fio/pkb.log#L8396),[rr](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/fio/pkb.log#L8420))</sup>                             | [yes](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/fio/pkb.log#L8471) | [yes](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/fio/pkb.log#L8348)<sup>`filesize`</sup> | no | no | no |
| `iperf` <br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/iperf_benchmark.py#L15))                      |   |   |   |   |   |   |   |
| `mesh_network`<br><sub><sup>a.k.a. [`netperf`](https://github.com/HewlettPackard/netperf)</sup></sub><br>([results]((results/local/mesh_network/pkb.log)), [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/mesh_network_benchmark.py#L15))               | [yes](https://hewlettpackard.github.io/netperf/training/Netperf.html#0.2.2Z141Z1.SUJSTF.7R2DBD.F) | [yes](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/mesh_network/pkb.log#L4386) | [yes](https://github.com/marcomicera/distributed-k8s/blob/master/results/local/mesh_network/pkb.log#L4389) | no | no | no | no |
| `mongodb_ycsb` <br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/mongodb_ycsb_benchmark.py))       |   |   |   |   |   |   |   |
| [`netperf`](https://github.com/HewlettPackard/netperf)<br>(results, [info](https://hewlettpackard.github.io/netperf/training/Netperf.html#0.2.2Z141Z1.SUJSTF.7R2DBD.E))                    | [yes](https://hewlettpackard.github.io/netperf/training/Netperf.html#0.2.2Z141Z1.SUJSTF.7R2DBD.F) |   |   |   |   |   |   |
| [`redis`](https://redis.io/)<br><sub><sup>a.k.a. [`memtier_benchmark`](https://github.com/RedisLabs/memtier_benchmark)</sup></sub><br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/redis_benchmark.py#L15))                      | [yes](https://github.com/RedisLabs/memtier_benchmark#connections) | yes<br><sub><sup>([`pkb.log`](results/local/redis/pkb.log):90493)</sub></sup> | yes<br><sub><sup>([`pkb.log`](results/local/redis/pkb.log):90523)</sub></sup> | no | no | *yes*<br><sub><sup>(([`pkb.log`](results/local/redis/pkb.log):88840)</sub></sup> | no |

</details>

<details>
<summary>Other potentially insteresting benchmarks not included in PerfKitBenchmarker</summary>
<br>

|                              | Distributed                        | File I/O                        | CPU performance               | Memory utilization | Avg. queue length | Scheduler successfulness                     | Useful busy time                   |
|------------------------------|------------------------------|---------------------------------|-------------------------------|--------------------|-------------------|----------------------------------------------|------------------------------------|
|                              | <sub><sup>Requires the cooperation of multiple nodes</sup></sub> | <sub><sup>Requests per second, throughput</sup></sub> | <sup><sub>Task completion time, latency</sup></sub> |                    | <sup><sub>Workload stats</sup></sub>    | <sup><sub># successful allocations / total allocations</sup></sub> | <sup><sub>Time spent scheduling / total time</sup></sub> |
| [PostgreSQL pg_bench](https://github.com/jberkus/pgKubernetesTutorial)<br>(results, info)          |                                 | yes                             |                               |                    |                   |                                              |                                    |
| Geekbench 3<br>(results, info)                  |                                 |                                 | yes                           |                    |                   |                                              |                                    |
| IOPing<br>(results, info)                       |                                 | yes                             | yes                           |                    |                   |                                              |                                    |
| IOzone<br>(results, info)                       |                                 |                                 |                               |                    |                   |                                              |                                    |

</details>

# How to run it

Benchmarks can be periodically launched as a [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) or one-time only.
This behavior is defined by [`start_cron.sh`](start_cron.sh) and [`start.sh`](start.sh) respectively.
[`start_cron.sh`](start_cron.sh) simply creates a [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) that executes [`start.sh`](start.sh).

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

<details>
<summary>Overview</summary>
<br>

1.  `./start_cron.sh $BENCHMARKS`:
    ```bash
    kubectl run --image=dk8s-cronjob \
        -- /bin/sh -c "./start.sh $BENCHMARKS"
    ```
    - `dk8s-cronjob` image:
        ```docker
        RUN git clone git@github.com:marcomicera/distributed-k8s.git
        ```
1. `./start.sh $BENCHMARKS`:
    ```bash
    # PerfKitBenchmarker creates pods using the dk8s-pkb image
    ```
    - `dk8s-pkb` image:
        ```docker
        # Dependencies
        # Launching benchmarks
        ```

</details>

### Steps

1. Clone this repository:
    ```bash
   $ git clone git@github.com:marcomicera/distributed-k8s.git
   $ cd distributed-k8s || exit
   ```
1. Set benchmark-specific flags in the [`benchmarks_conf.yaml` configuration file](benchmarks_conf.yaml)
1. Set other general config paramers in the [`start.sh` shell script](start.sh)
1. Launch [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) once specifying the [benchmarks](https://github.com/marcomicera/distributed-k8s#perfkitbenchmarker-supported-benchmarks-runnable-in-kubernetes) to be run:
    ```bash
    $ ./start.sh <benchmark_list>
    ```
    Or periodically with:
    ```bash
    $ ./start_cron.sh <benchmark_list>
    ```

# References
- Google's [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) ([description](https://cloud.google.com/free/docs/measure-compare-performance))
- The [Prometheus](https://prometheus.io/) monitoring system
  - [Grafana](https://grafana.com/) for time series analytics
- [Kubernetes](https://kubernetes.io/docs/reference/)
  - [`minikube`](https://github.com/kubernetes/minikube) (and its [documentation](https://minikube.sigs.k8s.io/docs/))
