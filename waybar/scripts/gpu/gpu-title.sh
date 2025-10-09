STATE_DIR="$HOME/.config/waybar/state"
CACHE="$STATE_DIR/gpu_stats_cache.json"

if [ ! -r "$CACHE" ]; then echo '{"text":"GPU"}'; exit; fi
mapfile -t GPU_STATS < <(jq -r '.name, .util, .temp, .mem_used, .mem_total' "$CACHE")

name="${GPU_STATS[0]}"
util="${GPU_STATS[1]}"
temp="${GPU_STATS[2]}"
mem_used="${GPU_STATS[3]}"
mem_total="${GPU_STATS[4]}"

if [[ "$mem_used" =~ ^[0-9]*\.?[0-9]+$ && "$mem_total" =~ ^[0-9]*\.?[0-9]+$ ]]; then
  echo "{\"text\":\"GPU\",\"tooltip\":\"${name} \\nUsage: ${util}% \\nTemperature: ${temp}°C \\nMemory: ${mem_used}/${mem_total} GB\"}"
else
  echo '{"text":"Mem N/A |","class":"gpu-mem-unknown"}'
fi
