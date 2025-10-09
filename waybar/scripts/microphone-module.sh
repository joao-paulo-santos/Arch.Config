#!/bin/bash
mic_volume=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
is_muted=$(echo "$mic_volume" | grep -q "MUTED" && echo "true" || echo "false")

if [ "$is_muted" = "true" ]; then
    icon="󰍭"
    css_class="microphone-muted"
else
    icon="󰍬"
    css_class="microphone-active"
fi

echo "{\"text\": \"$icon\", \"tooltip\": \"Microphone: $([ "$is_muted" = "true" ] && echo "Muted" || echo "Active")\", \"class\": \"$css_class\"}"