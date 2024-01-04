#!/bin/bash

log_info() {
    echo "INFO: $1"
}

log_error() {
    echo "ERROR: $1"
}

update_service() {
    local service_name="$1"
    local pod_selector="$2"

    pod_list=$(microk8s kubectl get pods --selector="$pod_selector" -o custom-columns=:metadata.name --no-headers)

    while IFS= read -r pod_name; do
        unknown_ports=$(microk8s kubectl exec "$pod_name" -- sh -c "netstat -tulnp" | grep "LISTEN" | awk '{print $4}' | awk -F ':' '{print $2}')

        if [ -z "$unknown_ports" ]; then
            log_error "Failed to retrieve unknown ports for $pod_name. Skipping update."
            continue
        fi

        # Remove the current service YAML file
        rm -f "$service_name-service.yaml"

        # Generate the new service YAML file
        cat <<EOF > "$service_name-service.yaml"
apiVersion: v1
kind: Service
metadata:
  name: $service_name
spec:
  ports:
EOF

        while IFS= read -r port; do
            cat <<EOF >> "$service_name-service.yaml"
    - name: "${service_name}-port-$port"
      port: $port
      targetPort: $port
EOF
        done <<< "$unknown_ports"

        cat <<EOF >> "$service_name-service.yaml"
  selector:
    io.kompose.service: $service_name
status:
  loadBalancer: {}
EOF

        # Apply the updated service configuration
        if microk8s kubectl apply -f "$service_name-service.yaml"; then
            log_info "Service configuration updated for $pod_name."
        else
            log_error "Failed to apply updated service configuration for $pod_name."
        fi

    done <<< "$pod_list"
}

# Update Datanode1 service
update_service "datanode" "io.kompose.service=datanode"

# Update Nodemanager1 service
update_service "nodemanager1" "io.kompose.service=nodemanager1"

# Port forwarding
microk8s kubectl port-forward service/datanode $(microk8s kubectl get service datanode1 -o=jsonpath='{.spec.ports[*].port}') --address 0.0.0.0 &
microk8s kubectl port-forward service/nodemanager1 $(microk8s kubectl get service nodemanager1 -o=jsonpath='{.spec.ports[*].port}') --address 0.0.0.0 &