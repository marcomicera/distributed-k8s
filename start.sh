#!/bin/bash

SLAVE_FOLDER=slave
PKB_VERSION=1.13.0
PKB_TAR=v${PKB_VERSION}.tar.gz
PKB_FOLDER=PerfKitBenchmarker-${PKB_VERSION}
PKB_URL=https://github.com/GoogleCloudPlatform/PerfKitBenchmarker/archive/${PKB_TAR}
PKB_FLAGS=--kubectl\ $(which kubectl)\ --kubeconfig\ ~/.kube/config

# Installing PerfKit Benchmarker dependencies
wget $PKB_URL
tar xzf $PKB_TAR
rm $PKB_TAR
mv $PKB_FOLDER $SLAVE_FOLDER
cd $SLAVE_FOLDER
sudo pip install -r requirements.txt
cd ..

# Building the docker image
. docker/build.sh

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

# The image is ready to be used by Perfkit:
# $SLAVE_FOLDER/pkb.py --image=ubuntu_ssh --kubectl\ $(which kubectl)\ --kubeconfig\ ~/.kube/config
