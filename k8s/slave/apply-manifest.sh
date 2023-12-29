#!/bin/bash

# Apply the Kubernetes manifests
sudo microk8s kubectl apply -f datanode-deployment.yaml
sudo microk8s kubectl apply -f datanode-service.yaml
sudo microk8s kubectl apply -f nodemanager1-service.yaml
sudo microk8s kubectl apply -f hadoop-env-configmap.yaml
sudo microk8s kubectl apply -f hadoop-datanode-persistentvolumeclaim.yaml
sudo microk8s kubectl apply -f nodemanager1-deployment.yaml

# Add more apply commands if needed

echo "Kubernetes manifests applied successfully!"
