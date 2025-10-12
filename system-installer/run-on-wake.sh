#!/bin/bash

# System sleep hook - runs scripts on sleep and wake
# This script should be symlinked to /lib/systemd/system-sleep/run-on-wake.sh
# Usage: sudo ln -sf ~/.config/system-installer/run-on-wake.sh /lib/systemd/system-sleep/run-on-wake.sh

# systemd-sleep calls this script with two arguments:
# $1: "pre" or "post" (before or after sleep)
# $2: "suspend", "hibernate", "hybrid-sleep", or "suspend-then-hibernate"

# Resolve the real script directory (follow symlinks)
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
ON_SLEEP_DIR="$SCRIPT_DIR/on-sleep"
ON_WAKE_DIR="$SCRIPT_DIR/on-wake"
LOG_FILE="/var/log/run-on-wake.log"

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Find the primary user (the one who owns the .config directory)
CONFIG_OWNER=$(stat -c %U "$(dirname "$SCRIPT_DIR")" 2>/dev/null)
if [ -z "$CONFIG_OWNER" ] || [ "$CONFIG_OWNER" = "root" ]; then
    # Fallback: find first non-system user
    CONFIG_OWNER=$(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 {print $1; exit}')
fi

if [ -z "$CONFIG_OWNER" ]; then
    log_message "Could not determine user to run scripts as"
    exit 1
fi

# Function to run scripts from a directory
run_scripts_from_dir() {
    local script_dir="$1"
    local phase="$2"
    local action="$3"
    
    if [ ! -d "$script_dir" ]; then
        log_message "No $phase directory found at $script_dir"
        return 0
    fi
    
    log_message "Running $phase scripts as user: $CONFIG_OWNER (action: $action)"
    
    # Find and execute all executable scripts in directory
    script_count=0
    for script in "$script_dir"/*; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            script_name=$(basename "$script")
            log_message "Executing $phase script: $script_name"
            
            # Run script as the config owner user
            if su "$CONFIG_OWNER" -c "$script" >> "$LOG_FILE" 2>&1; then
                log_message "$phase script '$script_name' completed successfully"
            else
                log_message "$phase script '$script_name' failed with exit code $?"
            fi
            
            ((script_count++))
        fi
    done
    
    if [ $script_count -eq 0 ]; then
        log_message "No executable $phase scripts found in $script_dir"
    else
        log_message "Executed $script_count $phase scripts"
    fi
    
    log_message "$phase script execution completed"
}

# Handle pre-sleep or post-sleep
case "$1" in
    "pre")
        log_message "System going to sleep (action: $2)"
        run_scripts_from_dir "$ON_SLEEP_DIR" "pre-sleep" "$2"
        ;;
    "post")
        log_message "System wake detected (action: $2)"
        run_scripts_from_dir "$ON_WAKE_DIR" "wake" "$2"
        ;;
    *)
        log_message "Unknown sleep phase: $1"
        exit 1
        ;;
esac