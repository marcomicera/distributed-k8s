# Contributing
This brief guide is addressed to developers aiming to extend this repository.

# Table of Contents

- [Customize benchmarks-dedicated CronJob files](#customize-benchmarks-dedicated-cronjob-files)
- [Change the Docker images to be used](#change-the-docker-images-to-be-used)
- [Add additional results writers](#add-additional-results-writers)
- [Add new benchmarks](#add-new-benchmarks)
- [Run benchmarks locally](#run-benchmarks-locally)

# Customize [benchmarks-dedicated CronJob files](#dedicated-cronjob-files-for-benchmarks)
Every benchmark has a dedicated YAML folder under [`yaml/benchmarks`](../yaml/benchmarks).
It is sufficient to edit whatever file under its folder without the need of applying anything immediately: [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/) will automatically merge and apply all the YAML specified by command line files upong launching [benchmarks-dedicated CronJob files](#dedicated-cronjob-files-for-benchmarks).

# Change the Docker images to be used
As described in the [Docker images section](#docker-images), there are currentl two Docker images being used:
> A [Kubernetes](https://kubernetes.io/) [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) launches periodic jobs in Docker containers.
The base [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) file of this repository [`yaml/base/dk8s-pkb-cronjob.yaml`](../yaml/base/dk8s-pkb-cronjob.yaml) mainly executes [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker), which in turn needs to launch benchmarks in Docker containers so that the [Kubernetes](https://kubernetes.io/) scheduler can allocate those onto pods.
[`marcomicera/dk8s-cronjob`](https://hub.docker.com/r/marcomicera/dk8s-cronjob) and [`marcomicera/dk8s-pkb`](https://hub.docker.com/r/marcomicera/dk8s-pkb) are the Docker images launched by the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) and [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker), respectively.

The first ([`marcomicera/dk8s-cronjob`](https://hub.docker.com/r/marcomicera/dk8s-cronjob)) is defined in the [base CronJob file `yaml/base/dk8s-pkb-cronjob.yaml`](../yaml/base/dk8s-pkb-cronjob.yaml).

The second image ([`marcomicera/dk8s-pkb`](https://hub.docker.com/r/marcomicera/dk8s-pkb)) is defined in the `PKB_IMAGE` variable of the [PKB's starting script `scripts/pkb/start.sh`](https://github.com/marcomicera/distributed-k8s/blob/master/scripts/pkb/start.sh).
Since the second must be launched by the former, one must build and upload the ([`marcomicera/dk8s-cronjob`](https://hub.docker.com/r/marcomicera/dk8s-cronjob)) image with its [build and upload script](../docker/dk8s-cronjob/build_and_upload.sh) upon changing the name of the image launched by [PerfKit Benchmarker](https://github.com/marcomicera/PerfKitBenchmarker) ([`marcomicera/dk8s-pkb`](https://hub.docker.com/r/marcomicera/dk8s-pkb)).

All Dockerfiles can be found in the [`docker`](../docker) folder.

# Add additional results writers
[PerfKit Benchmarker](https://github.com/marcomicera/PerfKitBenchmarker) can be easily extended with additional results writers.
It is enough to add a `SamplePublisher` child class in [`perfkitbenchmarker/publisher.py`](https://github.com/marcomicera/PerfKitBenchmarker/blob/master/perfkitbenchmarker/publisher.py) and add it to the list of publishers (`SampleCollector`'s class method `_PublishersFromFlags()`).\
Results publishers must be enabled by means of flags, which are declared at the beginning of that very same file.
[PerfKit Benchmarker](https://github.com/marcomicera/PerfKitBenchmarker) is finally launched by the [PKB's starting script](https://github.com/marcomicera/distributed-k8s/blob/master/scripts/pkb/start.sh), which holds a `PKB_FLAGS` variable containing all the flags to be passed to [PerfKit Benchmarker](https://github.com/marcomicera/PerfKitBenchmarker).

# Add new benchmarks
New benchmarks must be integrated in [PerfKit Benchmarker](https://github.com/marcomicera/PerfKitBenchmarker): guidelines on how to do so are available in its [`CONTRIBUTING.md` file](https://github.com/marcomicera/PerfKitBenchmarker/blob/master/CONTRIBUTING.md).

# Run benchmarks locally

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

1. [Run it](README.md#how-to-run-it)

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