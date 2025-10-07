#!/usr/bin/env bash
get_gpu_stats() {
  CACHE="/tmp/gpu_stats_cache.json"
  LOCK="/tmp/gpu_stats_cache.lock"
  MAX_AGE=10
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

CACHE="/tmp/gpu_stats_cache.json"
get_gpu_stats

if [ ! -r "$CACHE" ]; then echo '{"text":"GPU N/A","class":"gpu-usage-unknown"}'; exit; fi

mapfile -t GPU_STATS < <(jq -r '.name, .util, .temp, .mem_used, .mem_total' "$CACHE")
# Assign the array elements to individual named variables
name="${GPU_STATS[0]}"
util="${GPU_STATS[1]}"
temp="${GPU_STATS[2]}"
mem_used="${GPU_STATS[3]}"
mem_total="${GPU_STATS[4]}"

cls="gpu-usage-normal"
if [[ "$util" =~ ^[0-9]+$ ]]; then
  if [ "$util" -ge 90 ]; then cls="gpu-usage-critical"
  elif [ "$util" -ge 75 ]; then cls="gpu-usage-warn"
fi

else util="N/A"; cls="gpu-usage-unknown"; fi
echo "{\"text\":\"${util}%\",\"tooltip\":\"${name} \\nUsage: ${util}% \\nTemperature: ${temp}°C \\nMemory: ${mem_used}/${mem_total} GB\",\"class\":\"$cls\"}"
