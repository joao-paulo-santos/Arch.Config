#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.config/hypr/state"
STATE_FILE="$STATE_DIR/active-profile"
PROFILES_DIR="$HOME/.config/hypr/users"
TOFI="velo"

mkdir -p "$STATE_DIR"

if [ "$1" = "menu" ] || [ -z "${1:-}" ]; then
    SELECTED=$(for d in "$PROFILES_DIR"/*/; do
        [ -f "$d/init.lua" ] && basename "$d"
    done | "$TOFI" --pick --prompt-text "Hyprland profile: " 2>/dev/null)
    [ -z "$SELECTED" ] && exit 0
    set -- "$SELECTED"
fi

PROFILE="$1"

if [ ! -f "$PROFILES_DIR/$PROFILE/init.lua" ]; then
    notify-send "hyprland-profile" "Profile not found: $PROFILE" 2>/dev/null || true
    exit 1
fi

echo "$PROFILE" > "$STATE_FILE"
hyprctl reload
echo "Switched to hyprland profile: $PROFILE"
