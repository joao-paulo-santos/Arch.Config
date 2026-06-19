#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.config/hypr/state"
STATE_FILE="$STATE_DIR/active-profile"
PROFILES_DIR="$HOME/.config/hypr/users"
TOFI="/mnt/prometheus/Dev/Repos/velo/build/velo"

mkdir -p "$STATE_DIR"

if [ "$1" = "menu" ] || [ -z "${1:-}" ]; then
    SELECTED=$(ls -1 "$PROFILES_DIR" | sed 's/\.lua$//' | "$TOFI" --pick --prompt-text "Hyprland profile: " 2>/dev/null)
    [ -z "$SELECTED" ] && exit 0
    set -- "$SELECTED"
fi

PROFILE="$1"

if [ ! -f "$PROFILES_DIR/$PROFILE.lua" ]; then
    notify-send "hyprland-profile" "Profile not found: $PROFILE" 2>/dev/null || true
    exit 1
fi

echo "$PROFILE" > "$STATE_FILE"
hyprctl reload
echo "Switched to hyprland profile: $PROFILE"
