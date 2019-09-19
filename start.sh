#!/bin/bash

PERFKIT_BENCHMARKER_TAR_NAME=v1.13.0.tar.gz
PERFKIT_BENCHMARKER_RELEASE=https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/archive/${PERFKIT_BENCHMARKER_TAR_NAME}
PERFKIT_BENCHMARKER_FLAGS=--kubectl\ $(which kubectl)\ --kubeconfig\ ~/.kube/config

# Installing PerfKit Benchmarker dependencies
wget $PERFKIT_BENCHMARKER_RELEASE
tar xzf $PERFKIT_BENCHMARKER_TAR_NAME
rm $PERFKIT_BENCHMARKER_TAR_NAME
cd PerfKitBenchmarker-1.13.0
sudo pip install -r requirements.txt
cd ..

# Building the docker image
docker/build.sh

#
# Kubernetes cluster configuration
#

# Fixing $PATH so that the appropriate binaries can be found
# sudo mkdir -p /etc/systemd/system/kubelet.service.d
# sudo touch /etc/systemd/system/kubelet.service.d/10-env.conf
# sudo echo '[Service]
# > Environment=PATH=/opt/bin:/usr/bin:/usr/sbin:$PATH' > /etc/systemd/system/kubelet.service.d/10-env.conf

# Reboot the node?
# sudo reboot
