#!/usr/bin/env bash
TEMP_FILE="/sys/class/hwmon/hwmon3/temp1_input"

get_cpu_name() {
  grep "model name" /proc/cpuinfo 2>/dev/null | 
    head -n 1 | 
    cut -d: -f2 | 
    sed -e 's/^[[:space:]]*//' \
        -e 's/[[:space:]]*$//' \
        -e 's/[[:space:]]*[0-9]\+-Core Processor$//i'
}

cpu_usage() {
  read -r total1 idle1 < <(awk '/^cpu /{idle=$5; total=$2+$3+$4+$5+$6+$7+$8; print total, idle; exit}' /proc/stat)
  sleep 0.4
  read -r total2 idle2 < <(awk '/^cpu /{idle=$5; total=$2+$3+$4+$5+$6+$7+$8; print total, idle; exit}' /proc/stat)
  if [ -z "$total1" ] || [ -z "$total2" ] || [ "$total2" -le "$total1" ]; then
    echo 0
    return
  fi
  diff_total=$((total2 - total1))
  diff_idle=$((idle2 - idle1))
  echo $(( (diff_total - diff_idle) * 100 / diff_total ))
}

cpu_temp() {
  if [ -r "$TEMP_FILE" ]; then
    val=$(cat "$TEMP_FILE" 2>/dev/null)
    if printf '%s' "$val" | grep -Eq '^[0-9]+$'; then
      echo $(( (val + 500) / 1000 ))
      return
    fi
  fi
  echo "N/A"
}

cpu_model=$(get_cpu_name)
usage_percent=$(cpu_usage)
temp_c=$(cpu_temp)

if [ "$temp_c" = "N/A" ]; then
  cls="cpu-temp-unknown"
  temp_display="N/A"
elif [ "$temp_c" -ge 80 ]; then
  cls="cpu-temp-critical"
  temp_display="${temp_c}°C"
elif [ "$temp_c" -ge 70 ]; then
  cls="cpu-temp-warn"
  temp_display="${temp_c}°C"
else
  cls="cpu-temp-normal"
  temp_display="${temp_c}°C"
fi

if [ -z "$cpu_model" ]; then
    cpu_model="Unknown CPU"
fi

printf '{"text":"CPU %s%% %s","tooltip":"%s\\nCPU Usage: %s%%\\nCPU Temp: %s","class":"%s"}' \
  "$usage_percent" \
  "$temp_display" \
  "$cpu_model" \
  "$usage_percent" \
  "$temp_display" \
  "$cls"