#!/usr/bin/env bash
# Toggleable auto-clicker: left mouse click every 500ms (2×/sec).
# Bind: SUPER + SHIFT + CTRL + A
# First activation starts the loop; second activation stops it.
#
# Requires: ydotool + ydotoold daemon
#   sudo pacman -S ydotool
#   sudo systemctl enable --now ydotool

set -uo pipefail

PIDFILE="/tmp/hypr-autoclicker-${USER}.pid"

# Already running? → stop it.
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE" 2>/dev/null || true)
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null || true
        rm -f "$PIDFILE"
        notify-send -u low "Auto-clicker" "Stopped" 2>/dev/null || true
        exit 0
    fi
    rm -f "$PIDFILE"
fi

# Sanity check
if ! command -v ydotool >/dev/null 2>&1; then
    notify-send -u critical "Auto-clicker" "ydotool not installed — run: sudo pacman -S ydotool && sudo systemctl enable --now ydotool" 2>/dev/null || true
    exit 1
fi

# Start the loop fully detached so hyprctl exec_cmd returns immediately.
# 0xC0 = left button press (0x80) + release (0x40) = one full click.
nohup bash -c '
    while true; do
        ydotool click 0xC0
        sleep 0.5
    done
' >/dev/null 2>&1 &

echo $! > "$PIDFILE"
notify-send -u low "Auto-clicker" "Started — left click 2×/sec" 2>/dev/null || true
