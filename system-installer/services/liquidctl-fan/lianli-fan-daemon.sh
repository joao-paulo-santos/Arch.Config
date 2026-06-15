#!/usr/bin/env bash
set -euo pipefail

POLL=10
PREV_AIO="" PREV_CASE=""

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
    if   [ "$temp" -ge 85 ]; then echo 70
    elif [ "$temp" -ge 75 ]; then echo 50
    elif [ "$temp" -ge 65 ]; then echo 40
    else echo 30
    fi
}

map_speed_aio() {
    local temp=$1
    if   [ "$temp" -ge 85 ]; then echo 80
    elif [ "$temp" -ge 75 ]; then echo 60
    elif [ "$temp" -ge 65 ]; then echo 45
    else echo 35
    fi
}

while true; do
    temp=$(get_tctl || echo 60)

    aio=$(map_speed_aio "$temp")
    case_=$(map_speed "$temp")

    if [ "$aio" != "$PREV_AIO" ]; then
        liquidctl --match "Lian Li" set fan3 speed "$aio" 2>/dev/null || true
        PREV_AIO=$aio
    fi

    if [ "$case_" != "$PREV_CASE" ]; then
        liquidctl --match "Lian Li" set fan2 speed "$case_" 2>/dev/null || true
        liquidctl --match "Lian Li" set fan4 speed "$case_" 2>/dev/null || true
        PREV_CASE=$case_
    fi

    sleep $POLL
done
