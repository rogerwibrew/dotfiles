#!/bin/bash
# Bootstrap script for dotfiles deployment on fresh Ubuntu installation
# This script installs all required packages and symlinks configurations
# Supports both desktop (kelvin) and laptop (watt) configurations
#
# Execution Order:
# 1. System checks (Ubuntu version, user 'roger')
# 2. Add PPAs for newer software versions
# 3. System update
# 4. Install all packages (apt + snap)
# 5. Install external tools (Claude Code, nvm, cargo packages)
# 6. Create directory structure
# 7. Symlink configurations
# 8. Install web applications from webapps.txt
# 9. Setup display manager
# 10. Enable system services
# 11. Change default shell to zsh
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

# Check if running on Ubuntu
if [ ! -f /etc/lsb-release ]; then
  error "This script is designed for Ubuntu only"
fi

# Check Ubuntu version
source /etc/lsb-release
if [[ ! "$DISTRIB_ID" == "Ubuntu" ]]; then
  error "This script is designed for Ubuntu only"
fi

info "Detected Ubuntu $DISTRIB_RELEASE ($DISTRIB_CODENAME)"

# Set SCRIPT_DIR early, before any directory changes
# This ensures it's always correct regardless of where we cd to later
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Bootstrap script location: $SCRIPT_DIR"

# Get hostname to determine which config to use
HOSTNAME=$(hostname)

# Check if hostname is recognized, otherwise use generic config
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

# Update package lists
info "Updating package lists..."
sudo apt update || warning "apt update had some issues, continuing..."

# Install essential utilities needed by this script
info "Installing essential utilities..."
sudo apt install -y curl wget git || error "Failed to install essential utilities"
success "Essential utilities installed"

# =============================================================================
# ADD PPAs
# =============================================================================

info "Adding required PPAs..."

# Neovim PPA (for version 0.10+)
if ! grep -q "neovim-ppa/unstable" /etc/apt/sources.list.d/*.list 2>/dev/null; then
  info "Adding Neovim PPA..."
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  success "Neovim PPA added"
else
  success "Neovim PPA already added"
fi

# Update after adding PPAs
info "Updating package lists after PPA additions..."
sudo apt update || warning "apt update had some issues after PPA additions"

# =============================================================================
# SYSTEM UPDATE
# =============================================================================

info "Upgrading system packages..."
sudo apt upgrade -y || warning "System upgrade had some issues, continuing..."

# =============================================================================
# INSTALL APT PACKAGES
# =============================================================================

info "Installing packages from packages-ubuntu.txt..."

# Ensure all required config directories exist in dotfiles repo
info "Verifying dotfiles directory structure..."
mkdir -p "$SCRIPT_DIR/.config/kitty"
mkdir -p "$SCRIPT_DIR/.config/wofi"
mkdir -p "$SCRIPT_DIR/.config/mako"
mkdir -p "$SCRIPT_DIR/.config/yazi"
mkdir -p "$SCRIPT_DIR/.config/swaylock"
mkdir -p "$SCRIPT_DIR/.config/swayidle"
mkdir -p "$SCRIPT_DIR/.config/tmux"
mkdir -p "$SCRIPT_DIR/.config/unison"
mkdir -p "$SCRIPT_DIR/.config/waybar"
mkdir -p "$SCRIPT_DIR/.config/sway"
mkdir -p "$SCRIPT_DIR/.config/sway/config.d"
mkdir -p "$SCRIPT_DIR/.config/zsh"
mkdir -p "$SCRIPT_DIR/.config/shell"
success "Dotfiles directory structure verified"

# Extract package names (ignore comments and empty lines)
PACKAGES=$(grep -v '^#' "$SCRIPT_DIR/packages-ubuntu.txt" | grep -v '^$' | \
  sed 's/#.*//' | tr '\n' ' ')

if [ -n "$PACKAGES" ]; then
  sudo apt install -y $PACKAGES || warning "Some packages may have failed to install"
  success "APT packages installed"
else
  warning "No packages found in packages-ubuntu.txt"
fi

# =============================================================================
# INSTALL SNAP PACKAGES
# =============================================================================

info "Installing Snap packages..."

# Chromium browser (optional)
if ! snap list | grep -q chromium; then
  info "Installing Chromium via Snap..."
  sudo snap install chromium || warning "Chromium snap installation failed"
else
  success "Chromium already installed"
fi

# =============================================================================
# INSTALL CARGO PACKAGES
# =============================================================================

info "Installing Rust-based tools via Cargo..."

# Check if cargo is available
if command -v cargo &>/dev/null; then
  # eza (modern ls replacement)
  if ! command -v eza &>/dev/null; then
    info "Installing eza..."
    cargo install eza || warning "eza installation failed"
  else
    success "eza already installed"
  fi

  # yazi (terminal file manager)
  if ! command -v yazi &>/dev/null; then
    info "Installing yazi..."
    cargo install --locked yazi-fm yazi-cli || warning "yazi installation failed"
  else
    success "yazi already installed"
  fi
else
  warning "Cargo not available, skipping Rust-based tools"
  info "Install cargo and re-run bootstrap to install eza and yazi"
fi

# =============================================================================
# INSTALL GO PACKAGES
# =============================================================================

info "Installing Go-based tools..."

# Check if go is available
if command -v go &>/dev/null; then
  # lazygit (TUI for git)
  if ! command -v lazygit &>/dev/null; then
    info "Installing lazygit..."
    go install github.com/jesseduffield/lazygit@latest || warning "lazygit installation failed"
  else
    success "lazygit already installed"
  fi

  # lazydocker (TUI for docker)
  if ! command -v lazydocker &>/dev/null; then
    info "Installing lazydocker..."
    go install github.com/jesseduffield/lazydocker@latest || warning "lazydocker installation failed"
  else
    success "lazydocker already installed"
  fi

  # cliphist (clipboard history)
  if ! command -v cliphist &>/dev/null; then
    info "Installing cliphist..."
    go install go.senan.xyz/cliphist@latest || warning "cliphist installation failed"
  else
    success "cliphist already installed"
  fi
else
  warning "Go not available, skipping Go-based tools"
  info "Install golang and re-run bootstrap to install lazygit, lazydocker, cliphist"
fi

# =============================================================================
# INSTALL CLAUDE CODE
# =============================================================================

info "Installing Claude Code..."
if ! command -v claude &>/dev/null; then
  info "Downloading Claude Code installer..."
  if curl -fsSL https://claude.ai/install.sh -o /tmp/claude-install.sh; then
    info "Running Claude Code installer..."
    if bash /tmp/claude-install.sh; then
      rm -f /tmp/claude-install.sh
      # Source shell config to make claude available immediately
      export PATH="$HOME/.local/bin:$PATH"
      if command -v claude &>/dev/null; then
        success "Claude Code installed successfully"
      else
        warning "Claude Code installed but not in PATH yet"
        info "After reboot, run: source ~/.zprofile"
      fi
    else
      warning "Claude Code installation script failed"
      info "To install manually later: curl -fsSL https://claude.ai/install.sh | bash"
      rm -f /tmp/claude-install.sh
    fi
  else
    warning "Failed to download Claude Code installer (network issue?)"
    info "To install manually later: curl -fsSL https://claude.ai/install.sh | bash"
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
  # Create .nvm directory to ensure it exists
  mkdir -p "$NVM_DIR"

  # Download and run nvm install script
  if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
    success "nvm install script completed"
  else
    warning "nvm installation script failed (network issue?)"
  fi
else
  success "nvm already installed"
fi

# Install Node.js LTS via nvm
# Only attempt if nvm was successfully installed
if [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
  info "Installing Node.js LTS..."
  # Source nvm to make it available in this shell
  if \. "$NVM_DIR/nvm.sh" 2>/dev/null; then
    if nvm install --lts 2>/dev/null && nvm use --lts 2>/dev/null; then
      NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
      success "Node.js LTS installed ($NODE_VERSION)"
      info "Note: 'node' command will be available after opening a new shell or rebooting"
    else
      warning "Failed to install Node.js via nvm"
      info "After reboot, try: source ~/.zprofile && nvm install --lts"
    fi
  else
    warning "Failed to source nvm in current shell"
    info "After reboot, try: source ~/.zprofile && nvm install --lts"
  fi
else
  warning "nvm not found, skipping Node.js installation"
  info "To install nvm manually: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
  info "Then run: source ~/.zshrc && nvm install --lts"
fi

# =============================================================================
# SETUP NEOVIM
# =============================================================================

info "Setting up LazyVim..."

# Check if nvim config exists in dotfiles directory
if [ ! -d "$SCRIPT_DIR/.config/nvim" ]; then
  info "No Neovim config found in dotfiles, installing LazyVim..."

  # Clone LazyVim starter to dotfiles directory
  if git clone https://github.com/LazyVim/starter "$SCRIPT_DIR/.config/nvim" 2>/dev/null; then
    # Remove .git folder as recommended by LazyVim docs
    rm -rf "$SCRIPT_DIR/.config/nvim/.git" 2>/dev/null || true
    success "LazyVim cloned to dotfiles"
  else
    warning "LazyVim installation failed (network issue)"
  fi
else
  success "Neovim config already exists in dotfiles"
fi

# Clean up existing Neovim data/cache if requested
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  warning "Existing Neovim config detected at ~/.config/nvim (not a symlink)"
  echo -n "Remove it and use dotfiles version? (y/N): "
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    # Remove existing Neovim files
    warning "Removing existing Neovim config and data..."
    rm -rf "$HOME/.config/nvim" 2>/dev/null || true
    if [ -d "$HOME/.local/share/nvim" ]; then
      rm -rf "$HOME/.local/share/nvim" 2>/dev/null || true
    fi
    if [ -d "$HOME/.local/state/nvim" ]; then
      rm -rf "$HOME/.local/state/nvim" 2>/dev/null || true
    fi
    if [ -d "$HOME/.cache/nvim" ]; then
      rm -rf "$HOME/.cache/nvim" 2>/dev/null || true
    fi
    success "Cleaned up existing Neovim files"
  else
    info "Skipping cleanup - will preserve existing config"
  fi
fi

# =============================================================================
# CREATE DIRECTORY STRUCTURE
# =============================================================================

info "Creating necessary directories..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/wallpapers"

# Create home directory structure
info "Creating home directory structure..."
mkdir -p "$HOME/dev"
mkdir -p "$HOME/data"
mkdir -p "$HOME/downloads"
success "Home directory structure created (dev, data, downloads)"

# =============================================================================
# SYMLINK CONFIGURATION FILES
# =============================================================================

info "Symlinking configuration files..."

# Function to create symlink
create_symlink() {
  local source="$1"
  local target="$2"

  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target"
  fi

  ln -sfn "$source" "$target"
  success "Linked $source -> $target"
}

# Symlink config directories (non-hostname-specific)
create_symlink "$SCRIPT_DIR/.config/kitty" "$HOME/.config/kitty"
create_symlink "$SCRIPT_DIR/.config/wofi" "$HOME/.config/wofi"
create_symlink "$SCRIPT_DIR/.config/mako" "$HOME/.config/mako"
create_symlink "$SCRIPT_DIR/.config/yazi" "$HOME/.config/yazi"
create_symlink "$SCRIPT_DIR/.config/swaylock" "$HOME/.config/swaylock"
create_symlink "$SCRIPT_DIR/.config/swayidle" "$HOME/.config/swayidle"
create_symlink "$SCRIPT_DIR/.config/tmux" "$HOME/.config/tmux"
create_symlink "$SCRIPT_DIR/.config/unison" "$HOME/.config/unison"
create_symlink "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"

# Unison expects profiles in ~/.unison/ (doesn't support XDG)
# Create symlinks from ~/.unison/*.prf to ~/.config/unison/*.prf
mkdir -p "$HOME/.unison"
create_symlink "$HOME/.config/unison/dev-sync.prf" "$HOME/.unison/dev-sync.prf"
create_symlink "$HOME/.config/unison/data-sync.prf" "$HOME/.unison/data-sync.prf"

# Create waybar directory and symlink style.css
mkdir -p "$HOME/.config/waybar"
create_symlink "$SCRIPT_DIR/.config/waybar/style.css" \
  "$HOME/.config/waybar/style.css"

# Symlink hostname-specific Waybar config
if [ -f "$SCRIPT_DIR/.config/waybar/config-$HOSTNAME" ]; then
  info "Using hostname-specific Waybar config for $HOSTNAME"
  create_symlink "$SCRIPT_DIR/.config/waybar/config-$HOSTNAME" \
    "$HOME/.config/waybar/config"
else
  warning "No hostname-specific Waybar config found, using default"
  create_symlink "$SCRIPT_DIR/.config/waybar/config" \
    "$HOME/.config/waybar/config"
fi

# Create sway directory and symlink main config
mkdir -p "$HOME/.config/sway"
create_symlink "$SCRIPT_DIR/.config/sway/config" "$HOME/.config/sway/config"

# Symlink hostname-specific Sway config directory
if [ -d "$SCRIPT_DIR/.config/sway/config.d" ]; then
  create_symlink "$SCRIPT_DIR/.config/sway/config.d" "$HOME/.config/sway/config.d"
  success "Sway config.d directory linked"
fi

# Symlink shell configuration (XDG-compliant)
create_symlink "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"
create_symlink "$SCRIPT_DIR/.zprofile" "$HOME/.zprofile"
create_symlink "$SCRIPT_DIR/.config/zsh" "$HOME/.config/zsh"
create_symlink "$SCRIPT_DIR/.config/shell" "$HOME/.config/shell"

# Symlink XDG user directories
create_symlink "$SCRIPT_DIR/.config/user-dirs.dirs" "$HOME/.config/user-dirs.dirs"

# Create XDG cache directory for zsh history
mkdir -p "$HOME/.cache"

# Symlink scripts directory
create_symlink "$SCRIPT_DIR/scripts" "$HOME/scripts"

# Copy wallpapers
if [ -d "$SCRIPT_DIR/wallpapers" ] && \
  [ "$(ls -A "$SCRIPT_DIR/wallpapers")" ]; then
  info "Copying wallpapers..."
  cp -r "$SCRIPT_DIR/wallpapers/"* "$HOME/.local/share/wallpapers/"
  success "Wallpapers copied"
fi

# Make scripts executable
info "Making scripts executable..."
find "$SCRIPT_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \;
success "Scripts are now executable"

# =============================================================================
# INSTALL WEB APPLICATIONS
# =============================================================================

info "Installing web applications..."
if [ -f "$SCRIPT_DIR/scripts/setup/install-webapps.sh" ]; then
  "$SCRIPT_DIR/scripts/setup/install-webapps.sh" || warning "Webapp installation had some issues"
else
  warning "Webapp installer not found, skipping"
fi

# =============================================================================
# SETUP DISPLAY MANAGER
# =============================================================================

info "Setting up display manager..."

# Check if GDM is installed (Ubuntu default)
if command -v gdm3 &>/dev/null || systemctl list-unit-files | grep -q gdm3; then
  info "GDM display manager detected (Ubuntu default)"
  sudo systemctl enable gdm3.service
  success "GDM enabled and will start on boot"
else
  warning "No display manager detected"
  info "Install GDM with: sudo apt install gdm3"
fi

# =============================================================================
# ENABLE SYSTEM SERVICES
# =============================================================================

info "Enabling system services..."

# Audio services (user services)
systemctl --user enable --now pipewire.service 2>/dev/null || warning "Failed to enable pipewire (may need user session)"
systemctl --user enable --now pipewire-pulse.service 2>/dev/null || warning "Failed to enable pipewire-pulse (may need user session)"
systemctl --user enable --now wireplumber.service 2>/dev/null || warning "Failed to enable wireplumber (may need user session)"
success "Audio services configured (will start on login)"

# Network services
info "Enabling network services..."
sudo systemctl enable --now avahi-daemon.service
sudo systemctl enable --now ssh.service
success "Network services enabled (avahi, ssh)"
info "SSH is now available - connect via: ssh roger@$(hostname).local"

# Bluetooth service
info "Enabling bluetooth service..."
sudo systemctl enable --now bluetooth.service
success "Bluetooth service enabled"

# Printing service
info "Enabling printing service..."
sudo systemctl enable --now cups.service
success "CUPS printing service enabled"

# =============================================================================
# CONFIGURE MDNS
# =============================================================================

info "Configuring mDNS hostname resolution..."
if ! grep -q "mdns" /etc/nsswitch.conf; then
  sudo sed -i '/^hosts:/ s/files dns/files mdns4_minimal [NOTFOUND=return] dns/' /etc/nsswitch.conf
  success "mDNS configured in /etc/nsswitch.conf"
else
  success "mDNS already configured"
fi

# =============================================================================
# CHANGE DEFAULT SHELL
# =============================================================================

if [ "$SHELL" != "/usr/bin/zsh" ]; then
  info "Changing default shell to zsh..."
  chsh -s /usr/bin/zsh
  success "Default shell changed to zsh (takes effect on next login)"
else
  success "Default shell is already zsh"
fi

# =============================================================================
# DISPLAY FAILURE SUMMARY
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
  echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${YELLOW}Total warnings: ${#FAILURES[@]}${NC}"
  echo -e "${RED}═══════════════════════════════════════════════════════════${NC}"
  echo ""
fi

# =============================================================================
# FINAL SETUP INSTRUCTIONS
# =============================================================================

echo ""
success "Bootstrap complete!"
echo ""
info "Next steps:"
echo "  1. Restore SSH keys from USB:"
echo "     ~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh"
echo "  2. Run first-time Unison sync:"
echo "     ~/dotfiles/scripts/sync/first-sync.sh"
echo "  3. Reboot your system"
echo "  4. GDM login screen will appear"
echo "  5. Select Sway session and log in"
echo "  6. Unison will auto-sync dev and data folders in background"
echo "  7. Open Neovim - LazyVim will auto-install plugins (run :LazyHealth to verify)"
echo ""
info "SSH and Sync:"
echo "  Restore from USB      : ~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh"
echo "  Backup to USB         : ~/dotfiles/scripts/ssh/backup-ssh-to-usb.sh"
echo "  Connect to newton     : ~/dotfiles/scripts/ssh/connect-newton.sh"
echo "  First-time sync       : ~/dotfiles/scripts/sync/first-sync.sh"
echo "  Manual sync           : ~/dotfiles/scripts/sync/sync-now.sh"
echo "  View sync status      : tmux attach -t unison"
echo ""
info "Keybinding reference:"
echo "  Super + Shift + Return : Terminal"
echo "  Super + D              : Application launcher"
echo "  Super + W              : Close window"
echo "  Super + H/J/K/L        : Focus window (vim-style)"
echo "  Super + 1-9            : Switch workspaces"
echo "  Super + F              : Fullscreen"
echo "  Super + Ctrl + L       : Lock screen"
echo ""
