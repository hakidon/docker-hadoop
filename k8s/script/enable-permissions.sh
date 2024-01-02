#!/bin/bash

# Set executable permissions for file xxx
chmod +x ./init-mk8s.sh
chmod +x ./enable-mk8s.sh
chmod +x ../slave/apply-manifest.sh
chmod +x ../slave/update-hosts.sh
chmod +x ../slave/delete-all.sh
chmod +x ../master/apply-manifest.sh
chmod +x ../master/update-hosts.sh
chmod +x ../master/delete-all.sh

echo "Executable permissions for all execubtables."