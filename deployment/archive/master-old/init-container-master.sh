#!/bin/bash

# Set executable permissions for file xxx
echo "Enable permissions for all execubtables."

chmod +x ./init-mk8s.sh
chmod +x ./enable-mk8s.sh
chmod +x ../slave/apply-manifest.sh
chmod +x ../slave/update-hosts.sh
chmod +x ../slave/update-nodemanager.sh
chmod +x ../slave/delete-all.sh
chmod +x ../master/apply-manifest.sh
chmod +x ../master/update-hosts.sh
chmod +x ../master/delete-all.sh

current_user=$(whoami)

# Add the current user to the microk8s group
sudo usermod -a -G microk8s $current_user

# Switch to the microk8s group
newgrp microk8s

microk8s start

# Enable hostpath storage
microk8s enable hostpath-storage

echo ">> Microk8s setup completed <<"


sudo microk8s kubectl apply -f namenode-service.yaml
sudo microk8s kubectl apply -f resourcemanager-service.yaml
sudo microk8s kubectl apply -f historyserver-service.yaml
sudo microk8s kubectl apply -f hadoop-env-configmap.yaml
sudo microk8s kubectl apply -f historyserver-deployment.yaml
sudo microk8s kubectl apply -f hadoop-historyserver-persistentvolumeclaim.yaml
sudo microk8s kubectl apply -f namenode-deployment.yaml
sudo microk8s kubectl apply -f hadoop-namenode-persistentvolumeclaim.yaml
sudo microk8s kubectl apply -f resourcemanager-deployment.yaml

# Add more apply commands if needed

echo "Kubernetes manifests applied successfully!"

