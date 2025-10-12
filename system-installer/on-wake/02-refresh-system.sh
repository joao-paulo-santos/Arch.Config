#!/bin/bash

# Example wake script - refresh system status
# This script updates various system components that might be stale after wake

echo "System wake detected - refreshing components..."

# Refresh network manager connections
if command -v nmcli >/dev/null 2>&1; then
    echo "Refreshing NetworkManager..."
    nmcli device wifi rescan >/dev/null 2>&1 || true
fi

# Clear any stale lock files (be careful with this)
# Remove any stale sockets that might have been left from before sleep
find /tmp -user "$(whoami)" -name "*.sock" -mtime +1 -delete 2>/dev/null || true

echo "System refresh completed"