# `distributed-k8s`

## [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) + [`minikube`](https://github.com/kubernetes/minikube)
1. Start [`minikube`](https://github.com/kubernetes/minikube) on your local machine:
    ```bash
    $ minikube start
    ```
1. Add the current user to the `docker` group:
    ```bash
    $ newgrp docker
    ```
1. Launch [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker):
    ```bash
    $ ./start.sh
    ```

## Benchmarks comparison

#### [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker)-supported benchmarks runnable in Kubernetes
- [Complete list](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/tree/master/perfkitbenchmarker/linux_benchmarks)
- [Kubernetes benchmark set](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/benchmark_sets.py#L177)
  - [Updated unsupported set](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/providers/kubernetes/provider_info.py#L29)

|                              | Distributed                        | File I/O                        | CPU performance               | Memory utilization | Avg. queue length | Scheduler successfulness                     | Useful busy time                   |
|------------------------------|------------------------------|---------------------------------|-------------------------------|--------------------|-------------------|----------------------------------------------|------------------------------------|
|                              | <sub><sup>Requires the cooperation of multiple nodes</sup></sub> | <sub><sup>Requests per second, throughput</sup></sub> | <sup><sub>Task completion time, latency</sup></sub> |                    | <sup><sub>Workload stats</sup></sub>    | <sup><sub># successful allocations / total allocations</sup></sub> | <sup><sub>Time spent scheduling / total time</sup></sub> |
| `block_storage_workload`<br><sub><sup>a.k.a. [`fio`](https://fio.readthedocs.io/en/latest/fio_doc.html)</sup></sub><br>([results](results/block_storage_workload/pkb.log), [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/linux_benchmarks/block_storage_workloads_benchmark.py#L15)) | no | yes<sup>([sw](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L5964),[rr](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L5988),[sr](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L6012))</sup> | [yes](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L6037) | [yes](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L5964)<sup>`filesize`</sup> | no | no | no |
| `cassandra_ycsb` <br><sub><sup>Yahoo! Cloud Serving Benchmark</sup></sub><br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/linux_benchmarks/cassandra_ycsb_benchmark.py#L15))     |   |   |   |   |   |   |   |
| `cassandra_stress` <br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/linux_benchmarks/cassandra_stress_benchmark.py#L15))   |   |   |   |   |   |   |   |
| `cluster_boot`<br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/linux_benchmarks/cluster_boot_benchmark.py#L14))               | [no](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/linux_benchmarks/cluster_boot_benchmark.py#L65) |   |   |   |   |   |   |
| [`fio`](https://fio.readthedocs.io/en/latest/fio_doc.html)<br>([results](results/fio/pkb.log), [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/linux_benchmarks/fio_benchmark.py#L15))                        | no | yes<sup>([sw](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8348),[sr](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8372),[rw](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8396),[rr](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8420))</sup>                             | [yes](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8471) | [yes](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8348)<sup>`filesize`</sup> | no | no | no |
| `iperf` <br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/iperf_benchmark.py#L15))                      |   |   |   |   |   |   |   |
| `mesh_network`<br><sub><sup>a.k.a. [`netperf`](https://github.com/HewlettPackard/netperf)</sup></sub><br>([results]((results/mesh_network/pkb.log)), [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/linux_benchmarks/mesh_network_benchmark.py#L15))               | [yes](https://hewlettpackard.github.io/netperf/training/Netperf.html#0.2.2Z141Z1.SUJSTF.7R2DBD.F) | [yes](https://github.com/marcomicera/distributed-k8s/blob/ea6832ce5385a506135140c4e6a0d48416d32411/results/mesh_network/pkb.log#L4386) | [yes](https://github.com/marcomicera/distributed-k8s/blob/ea6832ce5385a506135140c4e6a0d48416d32411/results/mesh_network/pkb.log#L4389) | no | no | no | no |
| `mongodb_ycsb` <br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/master/perfkitbenchmarker/linux_benchmarks/mongodb_ycsb_benchmark.py))       |   |   |   |   |   |   |   |
| [`netperf`](https://github.com/HewlettPackard/netperf)<br>(results, [info](https://hewlettpackard.github.io/netperf/training/Netperf.html#0.2.2Z141Z1.SUJSTF.7R2DBD.E))                    | [yes](https://hewlettpackard.github.io/netperf/training/Netperf.html#0.2.2Z141Z1.SUJSTF.7R2DBD.F) |   |   |   |   |   |   |
| [`redis`](https://redis.io/)<br><sub><sup>a.k.a. [`memtier_benchmark`](https://github.com/RedisLabs/memtier_benchmark)</sup></sub><br>(results, [info](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/blob/6310f37df9fb80c019d8a8e39bd93e2a10753c72/perfkitbenchmarker/linux_benchmarks/redis_benchmark.py#L15))                      | [yes](https://github.com/RedisLabs/memtier_benchmark#connections) | yes<br><sub><sup>([`pkb.log`](results/redis/pkb.log):90493)</sub></sup> | yes<br><sub><sup>([`pkb.log`](results/redis/pkb.log):90523)</sub></sup> | no | no | *yes*<br><sub><sup>(([`pkb.log`](results/redis/pkb.log):88840)</sub></sup> | no |

#### Not included id [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker)

|                              | Distributed                        | File I/O                        | CPU performance               | Memory utilization | Avg. queue length | Scheduler successfulness                     | Useful busy time                   |
|------------------------------|------------------------------|---------------------------------|-------------------------------|--------------------|-------------------|----------------------------------------------|------------------------------------|
|                              | <sub><sup>Requires the cooperation of multiple nodes</sup></sub> | <sub><sup>Requests per second, throughput</sup></sub> | <sup><sub>Task completion time, latency</sup></sub> |                    | <sup><sub>Workload stats</sup></sub>    | <sup><sub># successful allocations / total allocations</sup></sub> | <sup><sub>Time spent scheduling / total time</sup></sub> |
| [PostgreSQL pg_bench](https://github.com/jberkus/pgKubernetesTutorial)<br>(results, info)          |                                 | yes                             |                               |                    |                   |                                              |                                    |
| Geekbench 3<br>(results, info)                  |                                 |                                 | yes                           |                    |                   |                                              |                                    |
| IOPing<br>(results, info)                       |                                 | yes                             | yes                           |                    |                   |                                              |                                    |
| IOzone<br>(results, info)                       |                                 |                                 |                               |                    |                   |                                              |                                    |

#### References
- Google's [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) ([description](https://cloud.google.com/free/docs/measure-compare-performance))
- The [Prometheus](https://prometheus.io/) monitoring system
  - [Grafana](https://grafana.com/) for time series analytics
- [Kubernetes](https://kubernetes.io/docs/reference/)
  - [`minikube`](https://github.com/kubernetes/minikube) (and its [documentation](https://minikube.sigs.k8s.io/docs/))
