#!/bin/bash

# Apply the Kubernetes manifests
sudo microk8s kubectl apply -f namenode-service.yaml
sudo microk8s kubectl apply -f resourcemanager-service.yaml
sudo microk8s kubectl apply -f historyserver-service.yaml
sudo microk8s kubectl apply -f hadoop-env-configmap.yaml
sudo microk8s kubectl apply -f historyserver-deployment.yaml
sudo microk8s kubectl apply -f hadoop-historyserver-persistentvolumeclaim.yaml
sudo microk8s kubectl apply -f namenode-deployment.yaml
sudo microk8s kubectl apply -f hadoop-namenode-persistentvolumeclaim.yaml
sudo microk8s kubectl apply -f resourcemanager-deployment.yaml
sudo microk8s kubectl apply -f datanode-deployment.yaml
sudo microk8s kubectl apply -f datanode-service.yaml
sudo microk8s kubectl apply -f hadoop-datanode-persistentvolumeclaim.yaml
# sudo microk8s kubectl apply -f datanode1-deployment.yaml
# sudo microk8s kubectl apply -f hadoop-datanode1-persistentvolumeclaim.yaml
sudo microk8s kubectl apply -f nodemanager1-deployment.yaml
sudo microk8s kubectl apply -f nodemanager1-service.yaml


# Add more apply commands if needed

echo "Kubernetes manifests applied successfully!"
