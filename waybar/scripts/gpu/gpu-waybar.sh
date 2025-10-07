if ! command -v nvidia-smi >/dev/null 2>&1; then
  printf '{"text":"GPU N/A","tooltip":"nvidia-smi missing","class":"gpu-temp-unknown"}'
  exit 0
fi

mapfile -t LINES < <(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null)

if [ "${#LINES[@]}" -eq 0 ]; then
  printf '{"text":"GPU N/A","tooltip":"nvidia-smi returned no data","class":"gpu-temp-unknown"}'
  exit 0
fi

for ln in "${LINES[@]}"; do
  ln_trim=$(echo "$ln" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [ -n "$ln_trim" ] || continue

  # split CSV into fields (handles spaces after commas)
  IFS=',' read -r util temp mem_used mem_total <<<"$(echo "$ln_trim" | sed 's/, */,/g')"
  util=${util:-N/A}
  temp=${temp:-N/A}
  mem_used=${mem_used:-0}
  mem_total=${mem_total:-0}

  # convert MiB to GiB with one decimal if numeric
  if printf '%s' "$mem_used" | grep -Eq '^[0-9]+([.][0-9]+)?$' && printf '%s' "$mem_total" | grep -Eq '^[0-9]+([.][0-9]+)?$'; then
    used_gb=$(awk "BEGIN {printf \"%.1f\", $mem_used/1024}")
    total_gb=$(awk "BEGIN {printf \"%.1f\", $mem_total/1024}")
  else
    used_gb="N/A"
    total_gb="N/A"
  fi

  # Determine temperature class (adjust thresholds if desired)
  # warn >= 85, critical >= 95
  cls="gpu-temp-normal"
  if printf '%s' "$temp" | grep -Eq '^[0-9]+$'; then
    if [ "$temp" -ge 85 ]; then
      cls="gpu-temp-critical"
    elif [ "$temp" -ge 75 ]; then
      cls="gpu-temp-warn"
    else
      cls="gpu-temp-normal"
    fi
    temp_display="${temp}°C"
  else
    cls="gpu-temp-unknown"
    temp_display="N/A"
  fi

  # Compact text; module-level class will be applied by Waybar CSS
  printf '{"text":"GPU %s%% %s %s/%s GB |","tooltip":"Usage: %s%%\\nTemp: %s\\nMemory: %s GiB / %s GiB","class":"%s"}' \
    "$util" "$temp_display" "$used_gb" "$total_gb" "$util" "$temp_display" "$used_gb" "$total_gb" "$cls"
  exit 0
done

printf '{"text":"GPU N/A","tooltip":"No usable GPU data","class":"gpu-temp-unknown"}'