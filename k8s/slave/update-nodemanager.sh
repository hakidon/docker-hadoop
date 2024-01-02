#!/bin/bash

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