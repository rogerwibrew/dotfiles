#!/bin/bash
# Rebuild and install slstatus with updated config
# Run this on kelvin after pulling latest dotfiles

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=========================================="
echo "Rebuilding slstatus"
echo "=========================================="

cd "$DOTFILES_DIR/suckless/slstatus"

# Copy hostname-specific config
HOSTNAME=$(hostname)
if [ -f "$DOTFILES_DIR/suckless/slstatus/config-$HOSTNAME.h" ]; then
    echo "==> Copying config-$HOSTNAME.h to config.h..."
    cp "$DOTFILES_DIR/suckless/slstatus/config-$HOSTNAME.h" config.h
else
    echo "WARNING: config-$HOSTNAME.h not found, using existing config.h"
fi

echo "==> Recompiling slstatus..."
sudo make clean install

echo "==> Restarting slstatus..."
pkill slstatus || true
sleep 1
slstatus &

echo ""
echo "✓ slstatus rebuilt and restarted"
echo ""
echo "Status bar should now show:"
echo "  Vol: XX% | Net: up | Disk: XX% | CPU: XX% | RAM: X.XG | Day DD Mon HH:MM"
echo ""
echo "If you don't see it yet, restart X11:"
echo "  Super+Shift+Q (logout and login again)"
