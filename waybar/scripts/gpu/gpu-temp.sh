#!/usr/bin/env bash
get_gpu_stats() { #nvidia
  STATE_DIR="$HOME/.config/waybar/state"
  mkdir -p "$STATE_DIR"
  CACHE="$STATE_DIR/gpu_stats_cache.json"
  LOCK="$STATE_DIR/gpu_stats_cache.lock"
  MAX_AGE=15
  exec 9>"$LOCK"
  if [ -f "$CACHE" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
    if [ "$age" -le "$MAX_AGE" ]; then return 0; fi
  fi
  if flock -n 9; then
    mapfile -t LINES < <(nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)
    if [ "${#LINES[@]}" -eq 0 ]; then
      echo '{"util":"N/A","temp":"N/A","mem_used":"N/A","mem_total":"N/A"}' > "$CACHE"
    else
      IFS=',' read -r name util temp mem_used mem_total <<<"$(echo "${LINES[0]}" | sed 's/, */,/g')"
      used_gb=$(awk "BEGIN{printf \"%.1f\", $mem_used/1024}")
      total_gb=$(awk "BEGIN{printf \"%.1f\", $mem_total/1024}")
      echo "{\"name\":\"$name\",\"util\":\"$util\",\"temp\":\"$temp\",\"mem_used\":\"$used_gb\",\"mem_total\":\"$total_gb\"}" > "$CACHE"
    fi
    flock -u 9
  fi
}

STATE_DIR="$HOME/.config/waybar/state"
CACHE="$STATE_DIR/gpu_stats_cache.json"
get_gpu_stats

if [ ! -r "$CACHE" ]; then echo '{"text":"Temp N/A","class":"gpu-temp-unknown"}'; exit; fi

mapfile -t GPU_STATS < <(jq -r '.name, .util, .temp, .mem_used, .mem_total' "$CACHE")

name="${GPU_STATS[0]}"
util="${GPU_STATS[1]}"
temp="${GPU_STATS[2]}"
mem_used="${GPU_STATS[3]}"
mem_total="${GPU_STATS[4]}"

cls="gpu-temp-normal"
if [[ "$temp" =~ ^[0-9]+$ ]]; then
  if [ "$temp" -ge 85 ]; then cls="gpu-temp-critical"
  elif [ "$temp" -ge 70 ]; then cls="gpu-temp-warn"
fi
else temp="N/A"; cls="gpu-temp-unknown"; fi
echo "{\"text\":\"${temp}°C\",\"tooltip\":\"${name} \\nUsage: ${util}% \\nTemperature: ${temp}°C \\nMemory: ${mem_used}/${mem_total} GB\",\"class\":\"$cls\"}"