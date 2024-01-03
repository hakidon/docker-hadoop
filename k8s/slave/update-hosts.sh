#!/bin/bash

# Get master IP address from user input
read -p "Enter the master IP address: " master_ip

# Create or overwrite the hosts file
echo "# Hosts file generated by script" > hosts

# # Get pod information and extract relevant details
# pod_info=$(microk8s kubectl get pods -o wide --no-headers)

# # Loop through each line of the pod information
# while IFS= read -r line; do
#     # Extract pod name and IP address
#     pod_name=$(echo "$line" | awk '{print $1}')
#     # Extract the IP address from the sixth field
#     ip_address=$(echo "$line" | awk '{print $6}')

#     # Check if the IP address is valid
#     if ! [[ "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
#         # If not valid, use the IP address from the eighth field
#         ip_address=$(echo "$line" | awk '{print $8}')
#     fi

#     # Extract the hostname (remove everything after the first hyphen)
#     hostname=$(echo "$pod_name" | awk -F- '{print $1}')

#     # Handle special case for nodemanager1
#     if [ "$hostname" == "nodemanager1" ]; then
#         hostname="nodemanager"
#     fi

#     # Append the entry to the hosts file
#     echo "$ip_address $hostname" >> hosts
#     # Append entries for namenode, resourcemanager, and historyserver
# done <<< "$pod_info"

echo "$master_ip namenode" >> hosts
echo "$master_ip resourcemanager" >> hosts
echo "$master_ip historyserver" >> hosts
echo "$master_ip nodemanager" >> hosts

# Get pod names
pod_names=$(microk8s kubectl get pods -o custom-columns=:metadata.name --no-headers)

# Loop through each pod and append the contents of the hosts file to /etc/hosts
while IFS= read -r pod_name; do
    # Copy the hosts file to a temporary directory inside the container
    microk8s kubectl cp hosts "$pod_name":/tmp/hosts

    # Append the contents of the hosts file to /etc/hosts inside the container
    microk8s kubectl exec "$pod_name" -- sh -c "cat /tmp/hosts >> /etc/hosts"

    # Remove the temporary hosts file
    microk8s kubectl exec "$pod_name" -- sh -c "rm /tmp/hosts"

    # Print a message for each successful append
    echo "Hosts file appended to /etc/hosts in $pod_name!"
done <<< "$pod_names"

echo "Hosts file appended to /etc/hosts in each container!"

