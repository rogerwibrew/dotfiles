#!/bin/bash
# Install Rust and CLI tools on kelvin
# Run this script on kelvin to get rustup, cargo, and all CLI tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

echo "=========================================="
echo "Installing Rust Toolchain on Kelvin"
echo "=========================================="
echo ""

# Set XDG-compliant paths
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"

# Install Rust via rustup
if [ ! -d "$RUSTUP_HOME" ]; then
    info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    success "Rust installed to $RUSTUP_HOME"
else
    success "Rust already installed at $RUSTUP_HOME"
fi

# Source cargo environment for this session
if [ -f "$CARGO_HOME/env" ]; then
    source "$CARGO_HOME/env"
    success "Cargo environment loaded"
fi

# Verify cargo is available
if ! command -v cargo &>/dev/null; then
    echo "ERROR: Cargo not found even after installation"
    echo "Try running: source $CARGO_HOME/env"
    exit 1
fi

echo ""
info "Cargo version: $(cargo --version)"
echo ""

# Install Rust CLI tools
info "Installing Rust CLI tools (this will take a while)..."
"$SCRIPT_DIR/install-rust-tools.sh"

echo ""
echo "=========================================="
success "Installation complete!"
echo "=========================================="
echo ""
info "Rust and CLI tools installed successfully"
echo ""
echo "Note: Shell configuration already includes cargo in PATH"
echo "  - .zprofile adds \$CARGO_HOME/bin to PATH"
echo "  - .config/shell/alias sets up tool aliases"
echo ""
echo "Open a new terminal or run: source ~/.zprofile"
echo ""
echo "Test commands:"
echo "  cargo --version"
echo "  rg --version"
echo "  eza --version"
