#!/bin/bash
# Launch TUI applications in kitty terminal
# Used for creating keybindings to TUI apps like lazygit, impala, btop, etc.

TUI_APP="$1"

if [ -z "$TUI_APP" ]; then
  echo "Usage: $0 <tui-app-name>"
  echo "Example: $0 lazygit"
  exit 1
fi

# Check if app is installed
if ! command -v "$TUI_APP" &>/dev/null; then
  notify-send -u critical "TUI App Not Found" "$TUI_APP is not installed"
  exit 1
fi

# Launch in new kitty window with app name as title
kitty --class="tui-$TUI_APP" --title="$TUI_APP" -e "$TUI_APP"
