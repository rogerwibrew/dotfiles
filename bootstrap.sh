#!/bin/bash
# Bootstrap script for dotfiles deployment on fresh Arch Linux install
# This script installs all required packages and symlinks configurations
# Supports both desktop (kelvin) and laptop (watt) configurations

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
  error "This script is designed for Arch Linux only"
fi

# Install essential utilities needed by this script
info "Installing essential utilities..."
sudo pacman -Sy --needed --noconfirm inetutils coreutils
success "Essential utilities installed"

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

# Install yay if not already installed
if ! command -v yay &>/dev/null; then
  info "Installing yay AUR helper..."
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ~
  success "yay installed"
else
  success "yay already installed"
fi

# Update system
info "Updating system..."
yay -Syu --noconfirm

# Read packages from packages.txt and install
info "Installing packages from packages.txt..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
mkdir -p "$SCRIPT_DIR/.config/hypr"
mkdir -p "$SCRIPT_DIR/.config/zsh"
mkdir -p "$SCRIPT_DIR/.config/shell"
success "Dotfiles directory structure verified"

# Extract package names (ignore comments and empty lines)
PACKAGES=$(grep -v '^#' "$SCRIPT_DIR/packages.txt" | grep -v '^$' |
  sed 's/#.*//' | tr '\n' ' ')

if [ -n "$PACKAGES" ]; then
  yay -S --needed --noconfirm $PACKAGES
  success "All packages installed"
else
  warning "No packages found in packages.txt"
fi

# Install AUR packages (commented in packages.txt)
info "Installing AUR packages..."
yay -S --needed --noconfirm hyprpicker wlogout 2>/dev/null ||
  warning "Some AUR packages may have failed"

# Install Dashlane CLI (not available on AUR)
info "Installing Dashlane CLI..."
"$SCRIPT_DIR/scripts/setup/install-dashlane-cli.sh" ||
  warning "Dashlane CLI installation failed"

# Install nvm (Node Version Manager) with XDG compliance
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
      success "Node.js LTS installed"
      node --version 2>/dev/null || true
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

# Setup NvChad for Neovim
info "Setting up NvChad..."
if [ -d "$HOME/.config/nvim" ]; then
  warning "Neovim config already exists, backing up to ~/.config/nvim.bak"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi
if git clone https://github.com/NvChad/starter "$HOME/.config/nvim"; then
  success "NvChad installed"
else
  warning "NvChad installation failed (network issue or already exists)"
fi

# Create necessary directories
info "Creating necessary directories..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/share/wallpapers"

# Create home directory structure
info "Creating home directory structure..."
mkdir -p "$HOME/dev"
mkdir -p "$HOME/data"
mkdir -p "$HOME/downloads"
success "Home directory structure created (dev, data, downloads)"

# Symlink configuration files
info "Symlinking configuration files..."

# Function to create symlink with backup
create_symlink() {
  local source="$1"
  local target="$2"

  if [ -e "$target" ] || [ -L "$target" ]; then
    warning "Backing up existing $target to ${target}.bak"
    mv "$target" "${target}.bak"
  fi

  ln -sf "$source" "$target"
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
create_symlink "$SCRIPT_DIR/.config/unison" "$HOME/.unison"

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

# Create hypr directory and symlink configs
mkdir -p "$HOME/.config/hypr"
create_symlink "$SCRIPT_DIR/.config/hypr/hyprpaper.conf" \
  "$HOME/.config/hypr/hyprpaper.conf"
create_symlink "$SCRIPT_DIR/.config/hypr/keybindings-apps.conf" \
  "$HOME/.config/hypr/keybindings-apps.conf"

# Symlink hostname-specific Hyprland config
if [ -f "$SCRIPT_DIR/.config/hypr/hyprland-$HOSTNAME.conf" ]; then
  info "Using hostname-specific Hyprland config for $HOSTNAME"
  create_symlink "$SCRIPT_DIR/.config/hypr/hyprland-$HOSTNAME.conf" \
    "$HOME/.config/hypr/hyprland.conf"
else
  warning "No hostname-specific config found, using default"
  create_symlink "$SCRIPT_DIR/.config/hypr/hyprland.conf" \
    "$HOME/.config/hypr/hyprland.conf"
fi

# Symlink shell configuration (XDG-compliant)
create_symlink "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"
create_symlink "$SCRIPT_DIR/.zprofile" "$HOME/.zprofile"
create_symlink "$SCRIPT_DIR/.config/zsh" "$HOME/.config/zsh"
create_symlink "$SCRIPT_DIR/.config/shell" "$HOME/.config/shell"

# Create XDG cache directory for zsh history
mkdir -p "$HOME/.cache"

# Symlink scripts directory
create_symlink "$SCRIPT_DIR/scripts" "$HOME/scripts"

# Copy wallpapers
if [ -d "$SCRIPT_DIR/wallpapers" ] &&
  [ "$(ls -A $SCRIPT_DIR/wallpapers)" ]; then
  info "Copying wallpapers..."
  cp -r "$SCRIPT_DIR/wallpapers/"* "$HOME/.local/share/wallpapers/"
  success "Wallpapers copied"
fi

# Make scripts executable
info "Making scripts executable..."
find "$SCRIPT_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} \;
success "Scripts are now executable"

# Setup SDDM display manager
info "Setting up SDDM display manager..."
sudo mkdir -p /usr/share/sddm/themes
sudo cp -r "$SCRIPT_DIR/sddm/themes/tokyo-night" /usr/share/sddm/themes/
sudo cp "$SCRIPT_DIR/sddm/sddm.conf" /etc/sddm.conf
sudo systemctl enable sddm.service
success "SDDM installed and configured with Tokyo Night theme"

# Enable services
info "Enabling system services..."
systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.service
systemctl --user enable --now wireplumber.service
success "Audio services enabled"

info "Enabling network services..."
sudo systemctl enable --now iwd.service
success "iwd service enabled (use 'impala' command to manage WiFi)"

# Change default shell to zsh
if [ "$SHELL" != "/usr/bin/zsh" ]; then
  info "Changing default shell to zsh..."
  chsh -s /usr/bin/zsh
  success "Default shell changed to zsh (takes effect on next login)"
else
  success "Default shell is already zsh"
fi

# Final setup instructions
echo ""
success "Bootstrap complete!"
echo ""
info "Next steps:"
echo "  1. Restore SSH keys (choose one method):"
echo "     From Dashlane: ~/dotfiles/scripts/ssh/restore-ssh-from-dashlane.sh"
echo "     From USB:     ~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh"
echo "  2. Reboot your system"
echo "  3. SDDM login screen will appear (Tokyo Night theme)"
echo "  4. Select Hyprland session and log in"
echo "  5. Start tmux (will auto-sync dev and data folders)"
echo "  6. Open Neovim and run :MasonInstallAll for LSP support"
echo ""
info "SSH and Sync:"
echo "  Restore from Dashlane : ~/dotfiles/scripts/ssh/restore-ssh-from-dashlane.sh"
echo "  Restore from USB      : ~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh"
echo "  Backup to USB         : ~/dotfiles/scripts/ssh/backup-ssh-to-usb.sh"
echo "  Connect to newton     : ~/dotfiles/scripts/ssh/connect-newton.sh"
echo "  Manual sync           : ~/dotfiles/scripts/sync/sync-now.sh"
echo ""
info "Keybinding reference:"
echo "  Super + Shift + Return : Terminal"
echo "  Super + D              : Application launcher"
echo "  Super + W              : Close window"
echo "  Super + J/K            : Cycle through windows"
echo "  Super + Return         : Make window master"
echo "  Super + H/L            : Switch workspaces"
echo "  Super + F              : Fullscreen"
echo "  Super + L              : Lock screen"
echo ""
