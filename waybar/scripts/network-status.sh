#!/bin/bash
STATE_DIR="$HOME/.config/waybar/state"
STATE_FILE="$STATE_DIR/waybar-network-toggle"

mkdir -p "$STATE_DIR"

if [ "$1" = "toggle" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm "$STATE_FILE"
        SHOW_DETAIL=false
    else
        touch "$STATE_FILE"
        SHOW_DETAIL=true
    fi
    exit 0
else
    if [ -f "$STATE_FILE" ]; then
        SHOW_DETAIL=true
    else
        SHOW_DETAIL=false
    fi
fi

# Wifi
wifi_status=$(nmcli -t -f DEVICE,TYPE,STATE device status | grep "wifi:connected")
if [ -n "$wifi_status" ]; then
    wifi_device=$(echo "$wifi_status" | cut -d: -f1)
    wifi_info=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep "^yes" | head -1)
    if [ -n "$wifi_info" ]; then
        ssid=$(echo "$wifi_info" | cut -d: -f2)
        signal=$(echo "$wifi_info" | cut -d: -f3)
        
        if [ "$SHOW_DETAIL" = "true" ]; then
            echo "{\"text\": \"$ssid ($signal%) \", \"tooltip\": \"WiFi: $ssid ($signal%)\", \"class\": \"wifi\"}"
        else
            echo "{\"text\": \"\", \"tooltip\": \"WiFi: $ssid ($signal%)\", \"class\": \"wifi\"}"
        fi
        exit 0
    fi
fi

# Ethernet
ethernet_status=$(nmcli -t -f DEVICE,TYPE,STATE device status | grep "ethernet:connected")
if [ -n "$ethernet_status" ]; then
    ethernet_device=$(echo "$ethernet_status" | cut -d: -f1)
    ip_info=$(nmcli -t -f IP4.ADDRESS dev show "$ethernet_device" | head -1 | cut -d: -f2)
    if [ -n "$ip_info" ]; then
        ip=$(echo "$ip_info" | cut -d/ -f1)
        
        if [ "$SHOW_DETAIL" = "true" ]; then
            echo "{\"text\": \"$ip 󰈁\", \"tooltip\": \"Ethernet: $ip\", \"class\": \"ethernet\"}"
        else
            echo "{\"text\": \"󰈁\", \"tooltip\": \"Ethernet: $ip\", \"class\": \"ethernet\"}"
        fi
        exit 0
    fi
fi

# No connection

if [ "$SHOW_DETAIL" = "true" ]; then
    echo "{\"text\": \"Disconnected 󰖪\", \"tooltip\": \"No network connection\", \"class\": \"disconnected\"}"
else
    echo "{\"text\": \"󰖪\", \"tooltip\": \"No network connection\", \"class\": \"disconnected\"}"
fi