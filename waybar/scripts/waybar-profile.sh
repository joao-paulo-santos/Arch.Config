#!/usr/bin/env bash
set -euo pipefail

WAYBAR_DIR="$HOME/.config/waybar"
PROFILES_DIR="$WAYBAR_DIR/profiles"
STATE_FILE="$WAYBAR_DIR/state/active-profile"
TOFI="/mnt/prometheus/Dev/Repos/hypr-tofi/build/hypr-tofi"

# Ensure state directory exists
mkdir -p "$WAYBAR_DIR/state"

if [ "$1" = "menu" ] || [ -z "${1:-}" ]; then
    SELECTED=$(ls -1 "$PROFILES_DIR" | "$TOFI" --pick --prompt-text "Waybar profile: " 2>/dev/null)
    [ -z "$SELECTED" ] && exit 0
    set -- "$SELECTED"
fi

PROFILE="$1"

if [ ! -d "$PROFILES_DIR/$PROFILE" ]; then
    notify-send "waybar-profile" "Profile not found: $PROFILE" 2>/dev/null || true
    echo "Profile not found: $PROFILE" >&2
    exit 1
fi

# Remember active profile
echo "$PROFILE" > "$STATE_FILE"

# Kill existing waybar instances for current user
pkill -u "$USER" -x waybar 2>/dev/null || true
sleep 0.3

# Launch with profile
waybar \
    --config "$PROFILES_DIR/$PROFILE/config.jsonc" \
    --style "$PROFILES_DIR/$PROFILE/style.css" >/dev/null 2>&1 &

echo "Switched to waybar profile: $PROFILE"
