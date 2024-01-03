#!/bin/bash

# Start microk8s
microk8s start

# Enable hostpath storage
microk8s enable hostpath-storage

echo ">> Microk8s setup completed <<"