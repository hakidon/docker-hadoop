#!/bin/bash
export KUBECONFIG=/path/to/your/kubeconfig.yaml

# Delete all deployments
microk8s kubectl delete deployments --all

# Delete all pods
microk8s kubectl delete pods --all

# Delete all services
microk8s kubectl delete services --all

echo "All deployments, pods, and services have been deleted."
