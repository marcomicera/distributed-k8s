# `distributed-k8s`

## `PerfkitBenchmarker`'s Kubernetes example
1. Add the current user to the `docker` group:
    ```bash
    $ newgrp docker
    ```
2. Start the main script:
    ```bash
    $ chmod u+x start.sh
    $ ./start.sh
    ```

#### References
- [Benchmarks comparison](https://docs.google.com/spreadsheets/d/1053fTwR_PzUTqyQ0ITIH-JTwg4id1GHyoA8dWPFDg1M/edit?usp=sharing)
  - Google's [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) ([description](https://cloud.google.com/free/docs/measure-compare-performance))
- The [Prometheus](https://prometheus.io/) monitoring system
  - [Grafana](https://grafana.com/) for time series analytics
- [Kubernetes](https://kubernetes.io/docs/reference/)
  - [`minikube`](https://github.com/kubernetes/minikube) (and its [documentation](https://minikube.sigs.k8s.io/docs/))
