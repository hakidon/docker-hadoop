#!/bin/bash

# Get the current user
current_user=$(whoami)

# Add the current user to the microk8s group
sudo usermod -a -G microk8s $current_user

# Switch to the microk8s group
newgrp microk8s