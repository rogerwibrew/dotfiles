#!/bin/bash
# Rebuild and reinstall dwm
# Run this after modifying ~/dotfiles/suckless/dwm/config.h

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DWM_DIR="$HOME/dotfiles/suckless/dwm"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[INFO]${NC} Rebuilding dwm..."

cd "$DWM_DIR"
sudo make clean install

echo -e "${GREEN}[SUCCESS]${NC} dwm rebuilt and installed"
echo ""
echo "To apply changes:"
echo "  Option 1: Mod+Shift+Q to quit dwm, then startx again"
echo "  Option 2: If dwm is in a loop in .xinitrc, it will restart automatically"
