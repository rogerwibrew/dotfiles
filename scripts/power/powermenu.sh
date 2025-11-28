#!/bin/bash
# Power menu using wofi
# Provides shutdown, reboot, suspend, logout options

options="Shutdown\nReboot\nSuspend\nLogout\nLock"

chosen=$(echo -e "$options" | wofi --dmenu \
    --prompt "Power Menu" \
    --width 300 \
    --height 250)

case $chosen in
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Suspend)
        systemctl suspend
        ;;
    Logout)
        hyprctl dispatch exit
        ;;
    Lock)
        swaylock -f
        ;;
esac
