#!/bin/bash

# Get master IP address from user input
read -p "Enter the master IP address: " master_ip

# Create or overwrite the hosts file
echo "# Hosts file generated by script" > hosts

# Get pod information and extract relevant details
pod_info=$(microk8s kubectl get pods -o wide --no-headers)

# Loop through each line of the pod information
while IFS= read -r line; do
    # Extract pod name and IP address
    pod_name=$(echo "$line" | awk '{print $1}')
    # Extract the IP address from the sixth field
    ip_address=$(echo "$line" | awk '{print $6}')

    # Check if the IP address is valid
    if ! [[ "$ip_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # If not valid, use the IP address from the eighth field
        ip_address=$(echo "$line" | awk '{print $8}')
    fi

    # Extract the hostname (remove everything after the first hyphen)
    hostname=$(echo "$pod_name" | awk -F- '{print $1}')

    # Handle special case for nodemanager1
    if [ "$hostname" == "nodemanager1" ]; then
        hostname="nodemanager"
    fi

    # Append the entry to the hosts file
    echo "$ip_address $hostname" >> hosts
    # Append entries for namenode, resourcemanager, and historyserver
done <<< "$pod_info"

echo "$master_ip namenode" >> hosts
echo "$master_ip resourcemanager" >> hosts
echo "$master_ip historyserver" >> hosts
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


log_info() {
    echo "INFO: $1"
}

log_error() {
    echo "ERROR: $1"
}

datanode1_pod=$(microk8s kubectl get pods --selector=io.kompose.service=datanode1 -o custom-columns=:metadata.name --no-headers)

while IFS= read -r pod_name; do
    # Check netstat -tulnp inside the datanode1 pod
    unknown_ports=$(microk8s kubectl exec "$pod_name" -- sh -c "netstat -tulnp" | grep "LISTEN" | awk '{print $4}' | awk -F ':' '{print $2}')

    if [ -z "$unknown_ports" ]; then
        log_error "Failed to retrieve unknown ports for $pod_name. Skipping update."
        continue
    fi

    # Remove the current datanode1-service.yaml
    rm -f datanode1-service.yaml

    # Generate the new datanode1-service.yaml
    cat <<EOF > datanode1-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: datanode1
spec:
  ports:
EOF

    while IFS= read -r port; do
        cat <<EOF >> datanode1-service.yaml
    - name: "datanode-port-$port"
      port: $port
      targetPort: $port
EOF
    done <<< "$unknown_ports"

    cat <<EOF >> datanode1-service.yaml
  selector:
    io.kompose.service: datanode1
status:
  loadBalancer: {}
EOF

    # Apply the updated service configuration
    if microk8s kubectl apply -f datanode1-service.yaml; then
        log_info "Service configuration updated for $pod_name."
    else
        log_error "Failed to apply updated service configuration for $pod_name."
    fi

done <<< "$datanode1_pod"