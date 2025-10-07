#!/bin/bash

# mon-bright-hyprctl.sh - Ultra-fast brightness control with background execution
# Usage: ./mon-bright-hyprctl.sh [increase|decrease] [amount]

# Default values
ACTION="${1:-increase}"
AMOUNT="${2:-10}"

# Static mapping based on your setup (much faster than ddcutil detect)
# DP-3 -> Display 1, DP-4 -> Display 2
declare -A MONITOR_MAP=(
    ["DP-3"]="1"
    ["DP-4"]="2"
)

# Get current monitor from hyprctl (fast)
MONITOR_NAME=$(hyprctl activeworkspace | grep -o 'on monitor [^:]*' | cut -d' ' -f3)

# Get ddcutil index from static mapping (instant)
DDCUTIL_INDEX="${MONITOR_MAP[$MONITOR_NAME]}"

if [[ -z "$DDCUTIL_INDEX" ]]; then
    echo "Error: Unknown monitor $MONITOR_NAME" >&2
    exit 1
fi

# Get current brightness and calculate new value
CURRENT_BRIGHTNESS=$(ddcutil --display "$DDCUTIL_INDEX" getvcp 10 | grep -oP 'current value =\s*\K\d+')

if [[ -z "$CURRENT_BRIGHTNESS" ]]; then
    echo "Error: Could not get current brightness" >&2
    exit 1
fi

# Calculate new brightness
if [[ "$ACTION" == "increase" ]]; then
    NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS + AMOUNT))
else
    NEW_BRIGHTNESS=$((CURRENT_BRIGHTNESS - AMOUNT))
fi

# Clamp to valid range
NEW_BRIGHTNESS=$((NEW_BRIGHTNESS > 100 ? 100 : NEW_BRIGHTNESS < 0 ? 0 : NEW_BRIGHTNESS))

# Set new brightness
ddcutil --display "$DDCUTIL_INDEX" setvcp 10 "$NEW_BRIGHTNESS"