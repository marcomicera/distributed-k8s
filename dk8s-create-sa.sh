#!/bin/bash

# Creating a ServiceAccount and its corresponding kubeconfig file
kubectl delete sa dk8s
scripts/kubernetes/auth/kubernetes_add_service_account_kubeconfig.sh dk8s .config/dk8s-kubeconfig

# Creating a Secret from the kubeconfig file
kubectl delete secret dk8s-kubeconfig
kubectl create secret generic dk8s-kubeconfig --from-file=.config/dk8s-kubeconfig
