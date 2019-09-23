# `distributed-k8s`

## `PerfkitBenchmarker` + `minikube`
1. Start `minikube` on your local machine:
    ```bash
    $ minikube start
    ```
1. Add the current user to the `docker` group:
    ```bash
    $ newgrp docker
    ```
1. Setup `PerfkitBenchmarker` with Kubernetes:
    ```bash
    $ chmod u+x *.sh
    $ ./setup.sh
    ```
1. Launch `PerfkitBenchmarker`:
    ```bash
    $ ./start.sh
    ```

## Benchmarks comparison

#### [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker)-supported benchmarks runnable in Kubernetes

|                              | File I/O                        | CPU performance               | Memory utilization | Avg. queue length | Scheduler successfulness                     | Useful busy time                   |
|------------------------------|---------------------------------|-------------------------------|--------------------|-------------------|----------------------------------------------|------------------------------------|
|                              | <sub><sup>Requests per second, throughput</sup></sub> | <sup><sub>Task completion time, latency</sup></sub> |                    | <sup><sub>Workload stats</sup></sub>    | <sup><sub># successful allocations / total allocations</sup></sub> | <sup><sub>Time spent scheduling / total time</sup></sub> |
| `block_storage_workload`     | yes<sup>([sw](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L5964),[rr](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L5988),[sr](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L6012))</sup> | [yes](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L6037) | [yes](https://github.com/marcomicera/distributed-k8s/blob/78aafa0ff6d35d1f848951c05f7a70b3dff15f2b/results/block_storage_workload/pkb.log#L5964)<sup>`filesize`</sup> | no | no | no |
| `cassandra_ycsb` (fails)     |   |   |   |   |   |   |
| `cassandra_stress` (fails)   |   |   |   |   |   |   |
| `cluster_boot`               |   |   |   |   |   |   |
| `fio`                        | yes<sup>([sw](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8348),[sr](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8372),[rw](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8396),[rr](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8420))</sup>                             | [yes](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8471) | [yes](https://github.com/marcomicera/distributed-k8s/blob/fd2c29cb7750840c8558451f7002c697c06ce996/results/fio/pkb.log#L8348)<sup>`filesize`</sup> | no | no | no |
| `iperf`                      | [yes](https://github.com/marcomicera/distributed-k8s/blob/ea6832ce5385a506135140c4e6a0d48416d32411/results/mesh_network/pkb.log#L4386) | [yes](https://github.com/marcomicera/distributed-k8s/blob/ea6832ce5385a506135140c4e6a0d48416d32411/results/mesh_network/pkb.log#L4389) | no | no | no | no |
| `mesh_network`               |   |   |   |   |   |   |
| `mongodb_ycsb` (fails)       |   |   |   |   |   |   |
| `netperf`                    |   |   |   |   |   |   |
| `redis`                      |   |   |   |   |   |   |

#### Not included id [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker)

|                              | File I/O                        | CPU performance               | Memory utilization | Avg. queue length | Scheduler successfulness                     | Useful busy time                   |
|------------------------------|---------------------------------|-------------------------------|--------------------|-------------------|----------------------------------------------|------------------------------------|
|                              | <sub><sup>Requests per second, throughput</sup></sub> | <sup><sub>Task completion time, latency</sup></sub> |                    | <sup><sub>Workload stats</sup></sub>    | <sup><sub># successful allocations / total allocations</sup></sub> | <sup><sub>Time spent scheduling / total time</sup></sub> |
| [PostgreSQL pg_bench](https://github.com/jberkus/pgKubernetesTutorial)          | yes                             |                               |                    |                   |                                              |                                    |
| Geekbench 3                  |                                 | yes                           |                    |                   |                                              |                                    |
| IOPing                       | yes                             | yes                           |                    |                   |                                              |                                    |
| IOzone                       |                                 |                               |                    |                   |                                              |                                    |

#### References
- Google's [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) ([description](https://cloud.google.com/free/docs/measure-compare-performance))
- The [Prometheus](https://prometheus.io/) monitoring system
  - [Grafana](https://grafana.com/) for time series analytics
- [Kubernetes](https://kubernetes.io/docs/reference/)
  - [`minikube`](https://github.com/kubernetes/minikube) (and its [documentation](https://minikube.sigs.k8s.io/docs/))
