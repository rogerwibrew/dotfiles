#!/bin/bash
# Bootstrap script for dotfiles deployment on fresh Debian Stable
# This script installs all required packages, compiles suckless tools,
# and symlinks configurations
#
# Execution Order:
# 1. System checks (Debian, user 'roger')
# 2. System update
# 3. Install build dependencies and apt packages
# 4. Setup Flatpak and install GUI apps
# 5. Install Rust via rustup
# 6. Install Rust CLI tools via cargo
# 7. Clone and compile suckless tools (dwm, dmenu)
# 8. Install external tools (Claude Code, nvm, Node.js)
# 9. Create directory structure
# 10. Symlink configurations
# 11. Configure X11 (Xresources, xinitrc)
# 12. Enable system services
# 13. Change default shell to zsh
#
# Note: This script is designed to be idempotent (safe to run multiple times)

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Array to track failures/warnings
declare -a FAILURES=()

# Helper functions
info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
  FAILURES+=("$1")
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Check if running on Debian
if [ ! -f /etc/debian_version ]; then
  error "This script is designed for Debian only"
fi

# Check it's actually Debian (not Ubuntu, which also has debian_version)
if [ -f /etc/lsb-release ]; then
  source /etc/lsb-release
  if [[ "$DISTRIB_ID" == "Ubuntu" ]]; then
    error "This script is for Debian, not Ubuntu. Use bootstrap-ubuntu.sh instead."
  fi
fi

DEBIAN_VERSION=$(cat /etc/debian_version)
info "Detected Debian $DEBIAN_VERSION"

# Check Debian version (recommend 12+ / Bookworm)
DEBIAN_MAJOR=$(echo "$DEBIAN_VERSION" | cut -d. -f1)
if [ "$DEBIAN_MAJOR" -lt 12 ]; then
  warning "Debian $DEBIAN_VERSION detected. This script is designed for Debian 12+ (Bookworm). Some packages may be outdated."
fi

# Set SCRIPT_DIR early, before any directory changes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Bootstrap script location: $SCRIPT_DIR"

# Get hostname to determine which config to use
HOSTNAME=$(hostname)

# Check if hostname is recognized
if [ "$HOSTNAME" != "kelvin" ] && [ "$HOSTNAME" != "watt" ]; then
  warning "Unknown hostname: $HOSTNAME (expected 'kelvin' or 'watt')"
  warning "Will use generic configuration without hostname-specific settings"
fi

info "Starting dotfiles bootstrap process for $HOSTNAME..."
info "User: $(whoami)"

# Verify we're running as roger
if [ "$(whoami)" != "roger" ]; then
  error "This script must be run as user 'roger'"
fi

# =============================================================================
# SYSTEM UPDATE
# =============================================================================

info "Updating system..."
sudo apt update || warning "apt update had issues"
sudo apt upgrade -y || warning "apt upgrade had issues"

# =============================================================================
# INSTALL APT PACKAGES
# =============================================================================

info "Installing essential build tools..."
sudo apt install -y build-essential git curl wget pkg-config || error "Failed to install build tools"

info "Installing X11 and display dependencies..."
sudo apt install -y \
  xorg xserver-xorg xinit x11-xserver-utils \
  libx11-dev libxft-dev libxinerama-dev \
  libfreetype6-dev libfontconfig1-dev \
  xclip xdotool || warning "Some X11 packages may have failed"

info "Installing packages from packages-debian.txt..."

# Ensure all required config directories exist in dotfiles repo
mkdir -p "$SCRIPT_DIR/.config/kitty"
mkdir -p "$SCRIPT_DIR/.config/yazi"
mkdir -p "$SCRIPT_DIR/.config/tmux"
mkdir -p "$SCRIPT_DIR/.config/unison"
mkdir -p "$SCRIPT_DIR/.config/zsh"
mkdir -p "$SCRIPT_DIR/.config/shell"

# Extract package names (ignore comments and empty lines)
PACKAGES=$(grep -v '^#' "$SCRIPT_DIR/packages-debian.txt" | grep -v '^$' | \
  sed 's/#.*//' | tr '\n' ' ')

if [ -n "$PACKAGES" ]; then
  sudo apt install -y $PACKAGES || warning "Some packages may have failed to install"
  success "APT packages installed"
else
  warning "No packages found in packages-debian.txt"
fi

# =============================================================================
# SETUP FLATPAK
# =============================================================================

info "Setting up Flatpak..."
if ! command -v flatpak &>/dev/null; then
  sudo apt install -y flatpak || warning "Flatpak installation failed"
fi

# Add Flathub repository
if command -v flatpak &>/dev/null; then
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
  success "Flathub repository added"

  # Install Chromium via Flatpak
  info "Installing Chromium via Flatpak..."
  flatpak install -y flathub org.chromium.Chromium || warning "Chromium Flatpak installation failed"

  # Install Steam via Flatpak (for gaming)
  info "Installing Steam via Flatpak..."
  flatpak install -y flathub com.valvesoftware.Steam || warning "Steam Flatpak installation failed"
fi

# =============================================================================
# INSTALL RUST
# =============================================================================

info "Installing Rust via rustup..."
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"

if [ ! -d "$RUSTUP_HOME" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  success "Rust installed"
else
  success "Rust already installed"
fi

# Source cargo environment
if [ -f "$CARGO_HOME/env" ]; then
  source "$CARGO_HOME/env"
fi

# =============================================================================
# INSTALL RUST CLI TOOLS
# =============================================================================

if command -v cargo &>/dev/null; then
  info "Installing Rust CLI tools..."
  "$SCRIPT_DIR/scripts/setup/install-rust-tools.sh" || warning "Some Rust tools may have failed"

  # Add cargo binaries to PATH for this session
  export PATH="$CARGO_HOME/bin:$PATH"
  success "Rust CLI tools added to PATH"
else
  warning "Cargo not available, skipping Rust CLI tools"
fi

# =============================================================================
# COMPILE SUCKLESS TOOLS
# =============================================================================

info "Compiling suckless tools..."

SUCKLESS_DIR="$SCRIPT_DIR/suckless"

# Clone and compile dwm
if [ ! -f /usr/local/bin/dwm ]; then
  info "Compiling dwm..."
  cd "$SUCKLESS_DIR"

  # Clone dwm if not present
  if [ ! -f dwm/dwm.c ]; then
    # Download dwm source
    if [ -d dwm-temp ]; then rm -rf dwm-temp; fi
    git clone https://git.suckless.org/dwm dwm-temp
    # Move source files to our dwm directory (keeping our config.h)
    cp dwm-temp/*.c dwm-temp/*.h dwm-temp/*.1 dwm-temp/Makefile dwm-temp/config.mk dwm/ 2>/dev/null || true
    cp dwm-temp/config.def.h dwm/ 2>/dev/null || true
    rm -rf dwm-temp
  fi

  cd dwm

  # Verify source files exist before compiling
  if [ ! -f dwm.c ] || [ ! -f Makefile ]; then
    error "dwm source files missing. Clone may have failed."
  fi

  sudo make clean install
  success "dwm compiled and installed"
else
  success "dwm already installed"
fi

# Clone and compile dmenu
if [ ! -f /usr/local/bin/dmenu ]; then
  info "Compiling dmenu..."
  cd "$SUCKLESS_DIR"

  # Clone dmenu if not present
  if [ ! -f dmenu/dmenu.c ]; then
    if [ -d dmenu-temp ]; then rm -rf dmenu-temp; fi
    git clone https://git.suckless.org/dmenu dmenu-temp
    cp dmenu-temp/*.c dmenu-temp/*.h dmenu-temp/*.1 dmenu-temp/Makefile dmenu-temp/config.mk dmenu/ 2>/dev/null || true
    cp dmenu-temp/config.def.h dmenu/ 2>/dev/null || true
    rm -rf dmenu-temp
  fi

  cd dmenu

  # Verify source files exist before compiling
  if [ ! -f dmenu.c ] || [ ! -f Makefile ]; then
    error "dmenu source files missing. Clone may have failed."
  fi

  sudo make clean install
  success "dmenu compiled and installed"
else
  success "dmenu already installed"
fi

cd "$SCRIPT_DIR"

# Clone and compile slstatus
if [ ! -f /usr/local/bin/slstatus ]; then
  info "Compiling slstatus..."
  cd "$SUCKLESS_DIR"

  # Clone slstatus if not present
  if [ ! -f slstatus/slstatus.c ]; then
    if [ -d slstatus-temp ]; then rm -rf slstatus-temp; fi
    git clone https://git.suckless.org/slstatus slstatus-temp
    cp slstatus-temp/*.c slstatus-temp/*.h slstatus-temp/*.1 slstatus-temp/Makefile slstatus-temp/config.mk slstatus/ 2>/dev/null || true
    rm -rf slstatus-temp
  fi

  cd slstatus

  # Use hostname-specific config if available, otherwise use generic
  if [ -f "$SCRIPT_DIR/suckless/slstatus/config-$HOSTNAME.h" ]; then
    info "Using slstatus config for $HOSTNAME"
    cp "$SCRIPT_DIR/suckless/slstatus/config-$HOSTNAME.h" config.h
  elif [ -f "$SCRIPT_DIR/suckless/slstatus/config.h" ]; then
    info "Using generic slstatus config"
    cp "$SCRIPT_DIR/suckless/slstatus/config.h" config.h
  else
    warning "No slstatus config found, using default"
  fi

  # Verify source files exist before compiling
  if [ ! -f slstatus.c ] || [ ! -f Makefile ]; then
    error "slstatus source files missing. Clone may have failed."
  fi

  sudo make clean install
  success "slstatus compiled and installed"
else
  success "slstatus already installed"
fi

cd "$SCRIPT_DIR"

# =============================================================================
# INSTALL CLAUDE CODE
# =============================================================================

info "Installing Claude Code..."
if ! command -v claude &>/dev/null; then
  if curl -fsSL https://claude.ai/install.sh -o /tmp/claude-install.sh; then
    if bash /tmp/claude-install.sh; then
      rm -f /tmp/claude-install.sh
      export PATH="$HOME/.local/bin:$PATH"
      success "Claude Code installed"
    else
      warning "Claude Code installation failed"
      rm -f /tmp/claude-install.sh
    fi
  else
    warning "Failed to download Claude Code installer"
  fi
else
  success "Claude Code already installed"
fi

# =============================================================================
# INSTALL NVM AND NODE.JS
# =============================================================================

info "Installing nvm..."
export NVM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"
if [ ! -d "$NVM_DIR" ]; then
  mkdir -p "$NVM_DIR"
  if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
    success "nvm installed"
  else
    warning "nvm installation failed"
  fi
else
  success "nvm already installed"
fi

# Install Node.js LTS
if [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  info "Installing Node.js LTS..."
  if \. "$NVM_DIR/nvm.sh" 2>/dev/null; then
    if nvm install --lts 2>/dev/null && nvm use --lts 2>/dev/null; then
      NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
      success "Node.js LTS installed ($NODE_VERSION)"
    else
      warning "Failed to install Node.js via nvm"
    fi
  fi
fi

# =============================================================================
# SETUP NEOVIM
# =============================================================================

info "Setting up LazyVim..."

if [ ! -f "$SCRIPT_DIR/.config/nvim/init.lua" ]; then
  if [ -d "$SCRIPT_DIR/.config/nvim" ]; then
    rm -rf "$SCRIPT_DIR/.config/nvim"
  fi

  if git clone https://github.com/LazyVim/starter "$SCRIPT_DIR/.config/nvim" 2>/dev/null; then
    rm -rf "$SCRIPT_DIR/.config/nvim/.git" 2>/dev/null || true
    success "LazyVim cloned"
  else
    warning "LazyVim installation failed"
  fi
else
  success "LazyVim already exists"
fi

# =============================================================================
# CREATE DIRECTORY STRUCTURE
# =============================================================================

info "Creating directory structure..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/wallpapers"
mkdir -p "$HOME/dev"
mkdir -p "$HOME/data"
mkdir -p "$HOME/downloads"
success "Directory structure created"

# =============================================================================
# SYMLINK CONFIGURATIONS
# =============================================================================

info "Symlinking configuration files..."

create_symlink() {
  local source="$1"
  local target="$2"

  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target"
  fi

  ln -sfn "$source" "$target"
  success "Linked $source -> $target"
}

# Core config directories
create_symlink "$SCRIPT_DIR/.config/kitty" "$HOME/.config/kitty"
create_symlink "$SCRIPT_DIR/.config/yazi" "$HOME/.config/yazi"
create_symlink "$SCRIPT_DIR/.config/tmux" "$HOME/.config/tmux"
create_symlink "$SCRIPT_DIR/.config/unison" "$HOME/.config/unison"
create_symlink "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"

# Unison expects profiles in ~/.unison/
mkdir -p "$HOME/.unison"
[ -f "$SCRIPT_DIR/.config/unison/dev-sync.prf" ] && \
  create_symlink "$SCRIPT_DIR/.config/unison/dev-sync.prf" "$HOME/.unison/dev-sync.prf"
[ -f "$SCRIPT_DIR/.config/unison/data-sync.prf" ] && \
  create_symlink "$SCRIPT_DIR/.config/unison/data-sync.prf" "$HOME/.unison/data-sync.prf"

# Shell configuration
create_symlink "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"
create_symlink "$SCRIPT_DIR/.zprofile" "$HOME/.zprofile"
create_symlink "$SCRIPT_DIR/.config/zsh" "$HOME/.config/zsh"
create_symlink "$SCRIPT_DIR/.config/shell" "$HOME/.config/shell"

# X11 configuration
create_symlink "$SCRIPT_DIR/.xinitrc" "$HOME/.xinitrc"
create_symlink "$SCRIPT_DIR/.Xresources" "$HOME/.Xresources"
[ -f "$SCRIPT_DIR/.Xresources-kelvin" ] && \
  create_symlink "$SCRIPT_DIR/.Xresources-kelvin" "$HOME/.Xresources-kelvin"
[ -f "$SCRIPT_DIR/.Xresources-watt" ] && \
  create_symlink "$SCRIPT_DIR/.Xresources-watt" "$HOME/.Xresources-watt"

# Scripts directory
create_symlink "$SCRIPT_DIR/scripts" "$HOME/scripts"

# XDG user directories
[ -f "$SCRIPT_DIR/.config/user-dirs.dirs" ] && \
  create_symlink "$SCRIPT_DIR/.config/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"

# Copy wallpapers
if [ -d "$SCRIPT_DIR/wallpapers" ] && [ "$(ls -A "$SCRIPT_DIR/wallpapers")" ]; then
  info "Copying wallpapers..."
  cp -r "$SCRIPT_DIR/wallpapers/"* "$HOME/.local/share/wallpapers/"
  success "Wallpapers copied"
fi

# Make scripts executable
info "Making scripts executable..."
find "$SCRIPT_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \;
chmod +x "$HOME/.xinitrc"
success "Scripts are now executable"

# =============================================================================
# ENABLE SYSTEM SERVICES
# =============================================================================

info "Enabling system services..."

# SSH
sudo systemctl enable --now ssh.service 2>/dev/null || \
  sudo systemctl enable --now sshd.service 2>/dev/null || \
  warning "SSH service enable failed"

# Avahi for mDNS
sudo systemctl enable --now avahi-daemon.service || warning "Avahi enable failed"

# Bluetooth
sudo systemctl enable --now bluetooth.service 2>/dev/null || warning "Bluetooth enable failed"

# CUPS printing
sudo systemctl enable --now cups.service 2>/dev/null || warning "CUPS enable failed"

success "System services enabled"

# Configure mDNS
info "Configuring mDNS hostname resolution..."
if ! grep -q "mdns" /etc/nsswitch.conf; then
  sudo sed -i '/^hosts:/ s/files dns/files mdns4_minimal [NOTFOUND=return] dns/' /etc/nsswitch.conf
  success "mDNS configured"
else
  success "mDNS already configured"
fi

# =============================================================================
# CHANGE DEFAULT SHELL
# =============================================================================

if [ "$SHELL" != "/usr/bin/zsh" ]; then
  info "Changing default shell to zsh..."
  chsh -s /usr/bin/zsh
  success "Default shell changed to zsh"
else
  success "Default shell is already zsh"
fi

# =============================================================================
# DISPLAY SUMMARY
# =============================================================================

if [ ${#FAILURES[@]} -gt 0 ]; then
  echo ""
  echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${RED}                    WARNINGS/FAILURES SUMMARY              ${NC}"
  echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
  echo ""
  for i in "${!FAILURES[@]}"; do
    echo -e "${YELLOW}[$((i+1))]${NC} ${FAILURES[$i]}"
  done
  echo ""
fi

echo ""
success "Bootstrap complete!"
echo ""
info "Next steps:"
echo "  1. Restore SSH keys from USB:"
echo "     ~/scripts/ssh/restore-ssh-from-usb.sh"
echo "  2. Run first-time Unison sync:"
echo "     ~/scripts/sync/first-sync.sh"
echo "  3. Log out and log back in (or reboot)"
echo "  4. Start X with: startx"
echo "  5. dwm will start automatically"
echo ""
info "Keybinding reference (dwm):"
echo "  Mod + Shift + Return : Terminal (kitty)"
echo "  Mod + d              : Application launcher (dmenu)"
echo "  Mod + w              : Close window"
echo "  Mod + j/k            : Focus next/prev window"
echo "  Mod + Return         : Swap to master"
echo "  Mod + h/l            : Resize master"
echo "  Mod + t              : Tiled layout"
echo "  Mod + f              : Monocle (fullscreen)"
echo "  Mod + 1-9            : Switch workspace"
echo "  Mod + Shift + q      : Quit dwm"
echo "  Mod + Ctrl + l       : Lock screen"
echo ""
info "Rust CLI tools aliased to original names:"
echo "  ls -> eza    |  cat -> bat    |  find -> fd"
echo "  grep -> rg   |  du -> dust    |  ps -> procs"
echo "  top -> btm   |  diff -> delta |  tldr -> tlrc"
echo ""
info "Original commands available with 'o' prefix: ols, ocat, ofind, etc."
echo ""
