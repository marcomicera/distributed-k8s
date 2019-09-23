#!/bin/bash

. util/config.sh
REPO=git@github.com:GoogleCloudPlatform/PerfKitBenchmarker.git

# Installing PerfKit Benchmarker dependencies
git clone $REPO $PKB_FOLDER
cd $PKB_FOLDER
sudo pip install -r requirements.txt
cd ..

# Kubernetes cluster configuration
sudo mkdir -p /etc/systemd/system/kubelet.service.d
sudo touch /etc/systemd/system/kubelet.service.d/10-env.conf
echo '[Service]
Environment=PATH=/opt/bin:/usr/bin:/usr/sbin:$PATH' | sudo tee /etc/systemd/system/kubelet.service.d/10-env.conf
