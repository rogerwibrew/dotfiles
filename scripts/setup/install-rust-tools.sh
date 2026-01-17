#!/bin/bash
# Install Rust CLI tools via cargo
# These replace traditional Unix tools with modern alternatives
#
# Run this after rustup is installed:
#   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#
# Tools are installed to ~/.cargo/bin (add to PATH in .zprofile)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check if cargo is available
if ! command -v cargo &>/dev/null; then
    error "Cargo not found. Install Rust first:"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

info "Installing Rust CLI tools via cargo..."
info "This may take a while on first run (compiling from source)"
echo ""

# Function to install a cargo package
install_tool() {
    local package=$1
    local binary=$2
    local description=$3

    if command -v "$binary" &>/dev/null; then
        success "$binary already installed"
    else
        info "Installing $package ($description)..."
        if cargo install "$package" 2>/dev/null; then
            success "$binary installed"
        else
            warning "Failed to install $package"
        fi
    fi
}

# Core replacements (most useful)
echo "=== Core Tools ==="
install_tool "eza" "eza" "modern ls replacement"
install_tool "bat" "bat" "cat with syntax highlighting"
install_tool "fd-find" "fd" "modern find replacement"
install_tool "ripgrep" "rg" "fast grep replacement"

echo ""
echo "=== Disk & Process Tools ==="
install_tool "du-dust" "dust" "intuitive du replacement"
install_tool "procs" "procs" "modern ps replacement"
install_tool "bottom" "btm" "graphical top replacement"

echo ""
echo "=== Navigation & Help ==="
install_tool "zoxide" "zoxide" "smarter cd with frecency"
install_tool "tlrc" "tlrc" "tldr client for quick help"
install_tool "broot" "broot" "interactive tree navigator"

echo ""
echo "=== Git & Development ==="
install_tool "git-delta" "delta" "better git diff viewer"
install_tool "lazygit" "lazygit" "terminal git UI"
install_tool "hyperfine" "hyperfine" "command benchmarking"

echo ""
echo "=== File Manager ==="
info "Installing yazi (terminal file manager)..."
if command -v yazi &>/dev/null; then
    success "yazi already installed"
else
    if cargo install --locked yazi-fm yazi-cli 2>/dev/null; then
        success "yazi installed"
    else
        warning "Failed to install yazi"
    fi
fi

echo ""
echo "========================================"
success "Rust CLI tools installation complete!"
echo "========================================"
echo ""
info "Tools installed to: ~/.cargo/bin"
info "Make sure ~/.cargo/bin is in your PATH"
info "Aliases are configured in ~/.config/shell/alias"
echo ""
info "Quick test commands:"
echo "  eza --version    # ls replacement"
echo "  bat --version    # cat replacement"
echo "  fd --version     # find replacement"
echo "  rg --version     # grep replacement"
echo "  btm --version    # top replacement"
