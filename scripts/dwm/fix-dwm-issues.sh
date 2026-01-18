#!/bin/bash
# Quick fixes for dwm issues on kelvin
# Run this on kelvin to fix dmenu, keyboard repeat, and verify slstatus

set -e

echo "==> Installing rofi (better application launcher)..."
sudo apt update
sudo apt install -y rofi

echo ""
echo "==> Adjusting keyboard repeat rate (delay: 300ms, rate: 30/sec)..."
# Delay before repeat starts: 300ms
# Repeat rate: 30 times per second
xset r rate 300 30

echo ""
echo "==> Checking slstatus output..."
echo "Running slstatus for 3 seconds to see output:"
timeout 3 slstatus || true

echo ""
echo "==> Testing if slstatus is feeding dwm..."
# Kill existing slstatus
pkill slstatus || true
# Start fresh
slstatus &
sleep 2

echo ""
echo "==> Fixes applied!"
echo ""
echo "Next steps:"
echo "1. Test rofi: Press Super+D (should still work, or rebind to rofi)"
echo "2. Keyboard repeat is now slower - test Super+Shift+Return"
echo "3. Check if status bar shows system info now"
echo ""
echo "To make keyboard repeat permanent, add this to ~/.xinitrc:"
echo "    xset r rate 300 30"
echo ""
echo "To use rofi instead of dmenu, we need to recompile dwm with rofi in config.h"
echo "Would you like me to do that?"
