#!/usr/bin/env bash
PIDFILE="$HOME/.config/hypr/scripts/node_init.pid"
if [ -s "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE")
  echo "Stopping node_init (PID $PID)..."
  kill -TERM "$PID"
  sleep 1
  if kill -0 "$PID" 2>/dev/null; then
    echo "Still running, force kill..."
    kill -KILL "$PID"
  fi
  rm -f "$PIDFILE"
else
  echo "No PID file found at $PIDFILE"
fi
