#!/bin/bash

# Service Setup Script
# Installs and enables systemd user services from the services/ directory
# Run this manually after a fresh install: ~/.config/system-installer/services/setup-services.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
LOCAL_BIN="$HOME_DIR/.local/bin"
SYSTEMD_USER_DIR="$HOME_DIR/.config/systemd/user"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

check_liquidctl_fan() {
    if ! command -v liquidctl &>/dev/null; then
        log_warning "liquidctl not installed - skipping liquidctl-fan service"
        return 1
    fi
    if ! liquidctl list 2>/dev/null | grep -qi "Lian Li"; then
        log_warning "No Lian Li device detected - skipping liquidctl-fan service"
        return 1
    fi
    return 0
}

install_service() {
    local service_dir="$1"
    local service_name
    service_name=$(basename "$service_dir")

    log_info "Setting up service: $service_name"

    # Hardware/dependency guards
    case "$service_name" in
        liquidctl-fan)
            if ! check_liquidctl_fan; then
                return 0
            fi
            ;;
    esac

    # Find the .service template file
    local service_file
    service_file=$(find "$service_dir" -maxdepth 1 -name "*.service" -type f | head -1)
    if [ -z "$service_file" ]; then
        log_error "No .service file found in $service_dir"
        return 1
    fi

    # Install daemon scripts to ~/.local/bin/
    mkdir -p "$LOCAL_BIN"
    for script in "$service_dir"/*.sh; do
        [ -f "$script" ] || continue
        script_name=$(basename "$script")
        [ "$script_name" = "setup-services.sh" ] && continue
        log_info "Installing script: $script_name -> $LOCAL_BIN/"
        cp "$script" "$LOCAL_BIN/"
        chmod +x "$LOCAL_BIN/$script_name"
    done

    # Install service file with __HOME__ substitution
    mkdir -p "$SYSTEMD_USER_DIR"
    local target_service="$SYSTEMD_USER_DIR/$(basename "$service_file")"
    sed "s|__HOME__|$HOME_DIR|g" "$service_file" > "$target_service"
    log_info "Installed service file: $target_service"

    # Reload systemd and enable
    local unit_name
    unit_name=$(basename "$service_file")
    systemctl --user daemon-reload
    systemctl --user enable "$unit_name"
    systemctl --user restart "$unit_name"
    log_success "Service '$unit_name' enabled and started"
}

# Main
log_info "Setting up systemd user services..."
log_info "Services directory: $SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR" ]; then
    log_error "Services directory not found"
    exit 1
fi

service_count=0
for service_dir in "$SCRIPT_DIR"/*/; do
    [ -d "$service_dir" ] || continue
    service_dir="${service_dir%/}"
    if [ -f "$service_dir/setup.sh" ]; then
        log_info "Running custom setup for $(basename "$service_dir")"
        bash "$service_dir/setup.sh"
    else
        install_service "$service_dir"
    fi
    ((service_count++))
done

if [ "$service_count" -eq 0 ]; then
    log_warning "No service directories found"
else
    log_success "Setup complete - $service_count service(s) processed"
fi
