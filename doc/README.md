# `distributed-k8s`: Kubernetes benchmarking

<!-- FIXME

<details>
<summary>Architecture</summary>
<br>

Periodic benchmarks are launched by means of the [`dk8s-pkb-cronjob.yaml`](dk8s-pkb-cronjob.yaml) file: it runs the [`scripts/pkb/start.sh`](scripts/pkb/start.sh) script inside pods to run [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker).
The [`dk8s-pkb-cronjob.yaml`](dk8s-pkb-cronjob.yaml) file has been generated with the [`start_cron.sh`](start_cron.sh) script.

Here is a description of these two script files:

1. `scripts/pkb/start.sh $BENCHMARKS` launches [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) once:
    - What [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) does:
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
        1. It runs [`PerfKitBenchmarker`](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) in a CronJob, using the `dk8s-cronjob` image
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