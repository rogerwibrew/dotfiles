#!/bin/bash
# Brightness notification script
# Shows current brightness level with mako notification

action="$1"

case "$action" in
    up)
        brightnessctl set +5%
        ;;
    down)
        brightnessctl set 5%-
        ;;
esac

# Get current brightness percentage
current=$(brightnessctl get)
max=$(brightnessctl max)
percentage=$((current * 100 / max))

notify-send -a brightness -u low -h string:x-canonical-private-synchronous:brightness \
    -h int:value:"$percentage" "Brightness: ${percentage}%" ""
