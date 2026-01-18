#!/bin/bash
# Apply fixes for dwm issues on kelvin
# Fixes: dmenu → rofi, keyboard repeat rate, verify slstatus
# Run this on kelvin after pulling latest dotfiles

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=========================================="
echo "Applying DWM Fixes on Kelvin"
echo "=========================================="
echo ""

# 1. Install rofi
echo "==> [1/4] Installing rofi (better application launcher)..."
if ! command -v rofi &>/dev/null; then
    sudo apt update
    sudo apt install -y rofi
    echo "    ✓ rofi installed"
else
    echo "    ✓ rofi already installed"
fi

# 2. Recompile dwm with rofi
echo ""
echo "==> [2/4] Recompiling dwm with rofi configuration..."
cd "$DOTFILES_DIR/suckless/dwm"
sudo make clean install
echo "    ✓ dwm recompiled and installed"

# 3. Test slstatus output
echo ""
echo "==> [3/4] Testing slstatus output..."
echo "    Killing existing slstatus process..."
pkill slstatus || true
sleep 1

echo "    Running slstatus for 3 seconds to capture output:"
timeout 3 slstatus 2>&1 || true
echo ""

# Restart slstatus
echo "    Starting slstatus in background..."
slstatus &
echo "    ✓ slstatus restarted (PID: $!)"

# 4. Summary
echo ""
echo "=========================================="
echo "Fixes Applied Successfully!"
echo "=========================================="
echo ""
echo "Changes made:"
echo "  1. ✓ Installed rofi"
echo "  2. ✓ Updated dwm to use rofi instead of dmenu"
echo "  3. ✓ Keyboard repeat rate reduced (300ms delay, 25/sec)"
echo "  4. ✓ Restarted slstatus"
echo ""
echo "Next steps:"
echo "  1. Restart X11 to apply all changes:"
echo "     - Press: Super+Shift+Q (quit dwm)"
echo "     - Login again via SDDM"
echo ""
echo "  2. After restart, test:"
echo "     - Super+D: Should open rofi (fuzzy search, only shows apps)"
echo "     - Super+Shift+Return: Terminal (slower repeat, less spawning)"
echo "     - Check status bar: Should show system info at top"
echo ""
echo "If status bar still doesn't show info after restart:"
echo "  - Check dwm log: cat ~/.dwm.log"
echo "  - Check if slstatus is running: pgrep slstatus"
echo "  - Manually run: slstatus (see what it outputs)"
echo ""
