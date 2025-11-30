#!/bin/bash
# Keybind reference popup using wofi
# Displays all Hyprland keybinds with descriptions in a searchable popup

set -euo pipefail

# Configuration
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
SOURCED_CONFIG="$HOME/.config/hypr/keybindings-apps.conf"

# Error handling
if [[ ! -f "$HYPR_CONFIG" ]]; then
    notify-send "Keybind Reference" "Config file not found: $HYPR_CONFIG" -u critical
    exit 1
fi

# Resolve $mainMod variable from config
resolve_main_mod() {
    local config="$1"
    grep "^\$mainMod = " "$config" 2>/dev/null | head -n1 | cut -d= -f2 | xargs || echo "SUPER"
}

# Extract description from comment
extract_description() {
    local line="$1"
    # Extract everything after the # symbol
    if [[ "$line" =~ \#(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
    else
        echo ""
    fi
}

# Parse keybind line and format for display
parse_keybind() {
    local line="$1"
    local main_mod="$2"

    # Skip if not a bind line
    if [[ ! "$line" =~ ^bind(e)?[[:space:]]*=[[:space:]]*(.+)$ ]]; then
        return
    fi

    local bind_content="${BASH_REMATCH[2]}"

    # Extract description if present
    local description
    description=$(extract_description "$line")

    # Remove comment from bind_content for parsing
    bind_content=$(echo "$bind_content" | sed 's/#.*//')

    # Parse: MODIFIERS, KEY, action, parameters
    IFS=',' read -r modifiers key action params <<< "$bind_content"

    # Clean up whitespace
    modifiers=$(echo "$modifiers" | xargs)
    key=$(echo "$key" | xargs)
    action=$(echo "$action" | xargs)
    params=$(echo "$params" | xargs)

    # Replace $mainMod with resolved value
    modifiers="${modifiers//\$mainMod/$main_mod}"

    # Format modifiers: "SUPER SHIFT" -> "SUPER+SHIFT"
    modifiers=$(echo "$modifiers" | tr ' ' '+')

    # Build keybind string
    if [[ -n "$modifiers" ]]; then
        keybind="${modifiers}+${key}"
    else
        keybind="${key}"
    fi

    # Generate description if not provided
    if [[ -z "$description" ]]; then
        case "$action" in
            exec)
                # Extract binary name from path
                local binary
                binary=$(basename "$(echo "$params" | awk '{print $1}')")
                description="Launch $binary"
                ;;
            workspace)
                description="Switch to workspace $params"
                ;;
            movetoworkspace)
                description="Move window to workspace $params"
                ;;
            layoutmsg)
                description="Layout: $params"
                ;;
            killactive)
                description="Close active window"
                ;;
            togglefloating)
                description="Toggle floating mode"
                ;;
            fullscreen)
                description="Toggle fullscreen"
                ;;
            exit)
                description="Exit Hyprland"
                ;;
            *)
                description="$action $params"
                ;;
        esac
    fi

    # Output formatted line: KEYBIND | Description
    printf "%-30s | %s\n" "$keybind" "$description"
}

# Parse all keybinds from a config file
parse_config_file() {
    local config_file="$1"
    local main_mod="$2"

    if [[ ! -f "$config_file" ]]; then
        return
    fi

    while IFS= read -r line; do
        parse_keybind "$line" "$main_mod"
    done < "$config_file"
}

# Main execution
main() {
    # Resolve $mainMod variable
    local main_mod
    main_mod=$(resolve_main_mod "$HYPR_CONFIG")

    # Build keybind list
    local keybinds=""

    # Parse main config
    keybinds+=$(parse_config_file "$HYPR_CONFIG" "$main_mod")
    keybinds+=$'\n'

    # Parse sourced config if it exists
    if [[ -f "$SOURCED_CONFIG" ]]; then
        keybinds+=$(parse_config_file "$SOURCED_CONFIG" "$main_mod")
    fi

    # Remove empty lines and sort
    keybinds=$(echo "$keybinds" | grep -v "^[[:space:]]*$" | sort -u)

    # Display in wofi
    echo "$keybinds" | wofi --dmenu \
        --prompt "Keybind Reference" \
        --width 700 \
        --height 300 \
        > /dev/null 2>&1
}

main "$@"
