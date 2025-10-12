#!/bin/bash

# Example wake script - restart user services
# This script restarts user systemd services that might need refreshing after wake

# Services to restart on wake
SERVICES_TO_RESTART=(
    "pipewire"
    "pipewire-pulse"  
    "wireplumber"
)

# Function to restart a user service
restart_user_service() {
    local service="$1"
    
    # Check if service exists and is loaded (add .service suffix if not present)
    local service_name="$service"
    if [[ ! "$service_name" == *.service ]]; then
        service_name="${service}.service"
    fi
    
    if systemctl --user list-unit-files "$service_name" >/dev/null 2>&1; then
        if systemctl --user is-active "$service" >/dev/null 2>&1; then
            echo "Restarting user service: $service"
            systemctl --user restart "$service" || echo "Failed to restart $service"
        else
            echo "Service $service is not active, skipping restart"
        fi
    else
        echo "Service $service not found, skipping"
    fi
}

# Restart services
for service in "${SERVICES_TO_RESTART[@]}"; do
    restart_user_service "$service"
done

echo "User services restart check completed"