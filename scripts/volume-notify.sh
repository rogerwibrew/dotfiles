#!/bin/bash
# Volume notification script
# Shows current volume level with mako notification

action="$1"

case "$action" in
    up)
        pamixer -i 5
        ;;
    down)
        pamixer -d 5
        ;;
    mute)
        pamixer -t
        ;;
esac

# Get current volume and mute status
volume=$(pamixer --get-volume)
muted=$(pamixer --get-mute)

if [ "$muted" = "true" ]; then
    notify-send -a volume -u low -h string:x-canonical-private-synchronous:volume \
        -h int:value:0 "Volume Muted" ""
else
    notify-send -a volume -u low -h string:x-canonical-private-synchronous:volume \
        -h int:value:"$volume" "Volume: ${volume}%" ""
fi
