#!/bin/bash

# Stop services gracefully before sleep
echo "$(date '+%Y-%m-%d %H:%M:%S') - Stopping services before sleep"

# Stop media players
if pgrep -x "mpv" > /dev/null; then
    echo "Stopping mpv processes"
    killall -TERM mpv
fi

if pgrep -x "vlc" > /dev/null; then
    echo "Stopping VLC processes"
    killall -TERM vlc
fi

# Pause any playing audio
if command -v playerctl >/dev/null 2>&1; then
    echo "Pausing media playback"
    playerctl pause-all
fi

# Stop development servers (if any)
if pgrep -f "npm.*start\|yarn.*start\|pnpm.*start" > /dev/null; then
    echo "Stopping development servers"
    pkill -f "npm.*start\|yarn.*start\|pnpm.*start"
fi

# Stop database services if running
if pgrep -x "mongod" > /dev/null; then
    echo "Stopping MongoDB"
    killall -TERM mongod
fi

if pgrep -x "redis-server" > /dev/null; then
    echo "Stopping Redis"
    killall -TERM redis-server
fi

echo "Services stopped gracefully"