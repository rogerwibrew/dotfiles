#!/bin/bash
# Screenshot script with multiple modes

mode="$1"
timestamp=$(date +%Y%m%d-%H%M%S)
screenshot_dir="$HOME/data/screenshots"
screenshot_file="$screenshot_dir/screenshot-$timestamp.png"

# Create screenshot directory if it doesn't exist
mkdir -p "$screenshot_dir"

case "$mode" in
    selection)
        # Screenshot selection to file
        grim -g "$(slurp)" "$screenshot_file"
        notify-send -a screenshot "Screenshot saved" \
            "$screenshot_file" -i "$screenshot_file"
        ;;
    selection-clipboard)
        # Screenshot selection to clipboard
        grim -g "$(slurp)" - | wl-copy
        notify-send -a screenshot "Screenshot copied to clipboard"
        ;;
    full)
        # Full screenshot to file
        grim "$screenshot_file"
        notify-send -a screenshot "Screenshot saved" \
            "$screenshot_file" -i "$screenshot_file"
        ;;
    full-clipboard)
        # Full screenshot to clipboard
        grim - | wl-copy
        notify-send -a screenshot "Screenshot copied to clipboard"
        ;;
    *)
        echo "Usage: $0 {selection|selection-clipboard|full|full-clipboard}"
        exit 1
        ;;
esac
