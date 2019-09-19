#!/bin/bash

SLAVE_FOLDER=slave
PKB_REPO=git@github.com:GoogleCloudPlatform/PerfKitBenchmarker.git
PKB_FLAGS=--kubectl\ $(which kubectl)\ --kubeconfig\ ~/.kube/config

# Installing PerfKit Benchmarker dependencies
git clone $PKB_REPO $SLAVE_FOLDER
cd $SLAVE_FOLDER
sudo pip install -r requirements.txt
cd ..

# Building the docker image
. docker/build.sh

#
# Kubernetes cluster configuration
#

# Fixing $PATH so that the appropriate binaries can be found
sudo mkdir -p /etc/systemd/system/kubelet.service.d
sudo touch /etc/systemd/system/kubelet.service.d/10-env.conf
echo '[Service]
Environment=PATH=/opt/bin:/usr/bin:/usr/sbin:$PATH' | sudo tee /etc/systemd/system/kubelet.service.d/10-env.conf

# Reboot the node?
# sudo reboot

# The image is ready to be used by Perfkit:
$SLAVE_FOLDER/pkb.py --image=ubuntu_ssh $PKB_FLAGS
