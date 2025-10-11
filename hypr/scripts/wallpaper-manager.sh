#!/bin/sh

handle() {
  case $1 in
    workspace*)
      str=$1
      i=$((${#str}-1))
      workspace="${str:$i:1}"
      case $workspace in
        1)
          swww img -o eDP-1 -t fade --transition-duration 1 /home/vitarsi/Pictures/Wallpapers/01.png
          ;;
        2)
          swww img -o eDP-1 -t fade --transition-duration 1 /home/vitarsi/Pictures/Wallpapers/02.png
          ;;
        3)
          swww img -o eDP-1 -t fade --transition-duration 1 /home/vitarsi/Pictures/Wallpapers/03.png
          ;;
        4)
          swww img -o eDP-1 -t fade --transition-duration 1 /home/vitarsi/Pictures/Wallpapers/04.png
          ;;
        5)
          swww img -o eDP-1 -t fade --transition-duration 1 /home/vitarsi/Pictures/Wallpapers/05.png
          ;;
        6 | 7 | 8 | 9 | 0)
          swww img -o eDP-1 -t fade --transition-duration 1 /home/vitarsi/Pictures/Wallpapers/06.png
          ;;
      esac
      ;;
  esac
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done