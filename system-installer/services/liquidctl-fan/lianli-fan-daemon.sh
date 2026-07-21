#!/usr/bin/env bash
set -euo pipefail

POLL=10
PREV=""
CHANNELS=(fan1 fan2 fan3 fan4)

get_tctl() {
    sensors -j 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for k, v in data.items():
    if 'k10temp' in k:
        if 'Tctl' in v:
            for vk, vv in v['Tctl'].items():
                if 'input' in vk:
                    print(int(vv))
                    sys.exit(0)
" 2>/dev/null
}

map_speed() {
    local temp=$1
    if   [ "$temp" -ge 85 ]; then echo 75
    elif [ "$temp" -ge 75 ]; then echo 55
    elif [ "$temp" -ge 65 ]; then echo 42
    else echo 32
    fi
}

while true; do
    temp=$(get_tctl || echo 60)
    speed=$(map_speed "$temp")

    if [ "$speed" != "$PREV" ]; then
        for ch in "${CHANNELS[@]}"; do
            liquidctl --match "Lian Li" set "$ch" speed "$speed" 2>/dev/null || true
        done
        PREV=$speed
    fi

    sleep $POLL
done
