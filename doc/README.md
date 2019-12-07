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

## 3.2 [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) fork changes
Besides minor bug fixes, the custom [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) fork has been extended with two additional "results writers", i.e., endpoints to which results are exported at the end of a single benchmark execution.
More specifically, it now includes a:
- CSV writer, which gradually adds entries to a CSV file as soon as benchmarks finish, and
- a [Prometheus](https://prometheus.io/) [Pushgateway](https://github.com/prometheus/pushgateway) exporter, which exposes results according to the [OpenMetrics](https://openmetrics.io/) format.

The [official Prometheus Python client](https://github.com/prometheus/client_python) has been used to accomplish the latter task.

<!-- 

\subsubsection{Including node IDs in benchmark results} \label{node_id}
While [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) does include physical node information in benchmark results (e.g., \texttt{lscpu} command output), it does not include [Kubernetes](https://kubernetes.io/) node IDs.
This information is essential to make a comparison between different hardware solutions (\cref{introduction}).
Since [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) is in charge of creating and configuring pods (\cref{existing_work}), its source code had to be extended to make pods aware of the node ID they were running on.
To do this, the [Kubernetes](https://kubernetes.io/) \textit{[Downward API](https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/\#the-downward-api)} comes in handy: it makes it possible to expose pod and container fields to a running container\footnote{\href{https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/\#the-downward-api}{kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/\#the-downward-api}}.
\autoref{kubenode} depicts the JSON snippet which made that possible.

\begin{lstlisting}[language=json, caption={Using the [Kubernetes](https://kubernetes.io/) \textit{[Downward API](https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/\#the-downward-api)} to inform containers of the node ID on which they are running.}, captionpos=below, label={kubenode}]
'env': [{
    'name': 'KUBE_NODE',
    'valueFrom': {
        'fieldRef': {
        'fieldPath': 'spec.nodeName'
        }
    }
}]
\end{lstlisting}

This way, [Kubernetes](https://kubernetes.io/) pods can retrieve the node ID of the physical machine on which they are running, and [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) can successfully include this information in the results.

\subsection{Running benchmarks periodically} \label{periodic_benchmarks}
Benchmarks are run periodically as a [Kubernetes](https://kubernetes.io/) \textit{[CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)}\footnote{\href{https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/}{kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/}}.
It periodically executes a shell script\footnote{\href{https://github.com/marcomicera/distributed-k8s/blob/master/start.sh}{\texttt{start.sh} on github.com/marcomicera/distributed-k8s}} that cycles through all the benchmarks to be executed (\cref{configuration}) and, for each one of them, it
\begin{mylist}
    \item checks whether it is compatible with [Kubernetes](https://kubernetes.io/), and
    \item builds a proper argument list to be passed to [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker)
\end{mylist}.

\subsubsection{Docker images}
A [Kubernetes](https://kubernetes.io/) [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) launches periodic jobs in Docker containers.
Our [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) mainly executes [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) (\cref{periodic_benchmarks}), which in turn needs to launch benchmarks in Docker containers so that the [Kubernetes](https://kubernetes.io/) scheduler can allocate those onto pods.
[`marcomicera/dk8s-cronjob`](https://hub.docker.com/r/marcomicera/dk8s-cronjob) and [`marcomicera/dk8s-pkb`](https://hub.docker.com/r/marcomicera/dk8s-pkb) are the Docker images launched by the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) and [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker), respectively\footnote{Available at \href{https://hub.docker.com/r/marcomicera/dk8s-cronjob}{hub.docker.com/r/marcomicera/dk8s-cronjob} and \href{https://hub.docker.com/r/marcomicera/dk8s-pkb}{hub.docker.com/r/marcomicera/dk8s-pkb}}.
The latter takes care of resolving most of the dependencies needed by benchmarks so that [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) will not waste any other time doing so.
The former
\begin{mylist}
    \item installs the [Kubernetes](https://kubernetes.io/) command-line tool \texttt{kubectl}, and
    \item downloads the main repository of this project\footnote{\href{https://github.com/marcomicera/distributed-k8s}{github.com/marcomicera/distributed-k8s}}, which also contains the previously-mentioned [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) fork\footnote{\href{https://github.com/marcomicera/PerfKitBenchmarker}{github.com/marcomicera/PerfKitBenchmarker}} as a git submodule
\end{mylist}.

\subsection{Passing files to containers}
Containers launched by the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) need to find two files in their filesystem: a benchmarks configuration file and a [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/}{kubeconfig} file, both described in \cref{benchmarks_conf} and \cref{kubeconfig}.
This is achieved by creating [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/secret/}{Secrets} from these two files (\autoref{benchmarks_conf_secret} and \autoref{kubeconfig_secret}).
\autoref{secret_mounting} depicts a code snippet from the \href{https://github.com/marcomicera/distributed-k8s/blob/master/cronjob.yaml}{\texttt{cronjob.yaml}} file that shows how they are mounted in containers' filesystem.

\begin{lstlisting}[language=yaml, caption={Mounting secrets into containers' filesystem.}, captionpos=below, label={secret_mounting}]
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
\end{lstlisting}

\section{Guide}
This guide refers to the \href{https://github.com/marcomicera/distributed-k8s}{github.com/marcomicera/distributed-k8s} repository, clonable with the following command:

\begin{lstlisting}[language=bash, caption={Main repository cloning command.}, captionpos=below, label={cloning}]
$ git clone git@github.com:marcomicera/distributed-k8s.git
$ cd distributed-k8s
\end{lstlisting}

\subsection{Configuration} \label{configuration}
This section describes all configuration steps to be made before launching benchmarks.

\subsubsection{Number of [Kubernetes](https://kubernetes.io/) pods} \label{benchmarks_conf}
The number of [Kubernetes](https://kubernetes.io/) pods to be used for every benchmark is defined in the \href{https://github.com/marcomicera/distributed-k8s/blob/master/benchmarks-conf.yaml}{\texttt{{\justify}benchmarks-conf.yaml}} configuration file.

\begin{lstlisting}[language=yaml, caption={Benchmarks configuration file snippet showing how to set the number of [Kubernetes](https://kubernetes.io/) pods to use for the \texttt{block\_storage\_workload} benchmark.}, captionpos=below, label={benchmarks_conf_yaml}]
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
\end{lstlisting}

It is worth noticing that [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) uses the term \textit{VM} as a generalization of \textit{[Kubernetes](https://kubernetes.io/) pod} since it supports multiple cloud providers.

Finally, the user needs to create a [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/secret/}{Secret} from this file.

\begin{lstlisting}[language=bash, caption={Creating a secret from the benchmarks configuration file.}, captionpos=below, label={benchmarks_conf_secret}]
$ kubectl create secret generic dk8s-benchconfig --from-file=benchmarks-conf.yaml
\end{lstlisting}

This will make this file available to the container running [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker).

\subsubsection{[CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) frequency}
Next, the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) frequency can be adjusted in the \href{https://github.com/marcomicera/distributed-k8s/blob/master/cronjob.yaml}{\texttt{cronjob.yaml}} file:

\begin{lstlisting}[language=yaml, caption={Setting the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) frequency: example with 30 minutes.}, captionpos=below, label={cronjob_frequency}]
schedule: '*/30 * * * *'
\end{lstlisting}

The schedule follows the \href{https://en.wikipedia.org/wiki/Cron}{Cron} format\footnote{\href{https://en.wikipedia.org/wiki/Cron}{en.wikipedia.org/wiki/Cron}}.

\subsubsection{Experiment configuration file}
The \href{https://github.com/marcomicera/distributed-k8s/blob/master/experiment-conf.yaml}{\texttt{experiment-conf.yaml}} file contains two experiment options, namely
\begin{mylist}
    \item the [Prometheus](https://prometheus.io/) [Pushgateway](https://github.com/prometheus/pushgateway) address, and
    \item the list of benchmarks to run
\end{mylist}.

\begin{lstlisting}[language=yaml, caption={An example of an experiment configuration file.}, captionpos=below, label={experiment_conf_yaml}]
apiVersion: v1
data:
  benchmarks: cluster_boot fio
  pushgateway: pushgateway.address.test
kind: ConfigMap
\end{lstlisting}

Experiments can be chosen amongst this list:

\begin{multicols}{2}
\begin{itemize}
    \item \texttt{block\_storage\_workload}
    \item \texttt{cassandra\_ycsb}
    \item \texttt{cassandra\_stress}
    \item \texttt{cluster\_boot}
    \item \texttt{fio}
    \item \texttt{iperf}
    \item \texttt{mesh\_network}
    \item \texttt{mongodb\_ycsb}
    \item \texttt{netperf}
    \item \texttt{redis}
\end{itemize}
\end{multicols}

Finally, the user must apply the \href{https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/}{ConfigMap}:

\begin{lstlisting}[language=bash, caption={}, captionpos=below, label={experiment_conf_apply}]
$ kubectl apply -f experiment-conf.yaml
\end{lstlisting}

\subsubsection{Specifying the \href{https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/}{kubeconfig} file} \label{kubeconfig}
Similarly to \cref{benchmarks_conf}, also the [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/}{kubeconfig} file needs to be passed to containers as a [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/secret/}{Secret}:

\begin{lstlisting}[language=bash, caption={Creating a secret containing the [Kubernetes](https://kubernetes.io/) \href{https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/}{kubeconfig} file.}, captionpos=below, label={kubeconfig_secret}]
$ kubectl create secret generic dk8s-kubeconfig --from-file=<kubeconfig_path>
\end{lstlisting}

\subsection{Launching benchmarks}
It is enough to launch the [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) with:

\begin{lstlisting}[language=bash, caption={Launching period benchmarks.}, captionpos=below, label={cronjob_launch}]
$ kubectl apply -f cronjob.yaml
\end{lstlisting}

\section{Conclusions}
The resulting benchmarking tool\footnote{\href{https://github.com/marcomicera/distributed-k8s}{github.com/marcomicera/distributed-k8s}} allows users to periodically (\cref{periodic_benchmarks}) run various kinds of benchmarks (\cref{supported_benchmarks}) on a [Kubernetes](https://kubernetes.io/) cluster.
The custom [PerfKit Benchmarker](https://github.com/GoogleCloudPlatform/PerfKitBenchmarker) fork\footnote{\href{https://github.com/marcomicera/PerfKitBenchmarker}{github.com/marcomicera/PerfKitBenchmarker}} (\cref{custom_pkb}) includes physical node identifiers into benchmark results (\cref{node_id}) and gradually exposes them to a [Prometheus](https://prometheus.io/) [Pushgateway](https://github.com/prometheus/pushgateway) following the [OpenMetrics](https://openmetrics.io/) format.
The tool is configurable through a few handy configuration files (\cref{configuration}).

-->

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