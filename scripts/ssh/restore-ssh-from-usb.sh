#!/bin/bash
# Restore SSH keys from USB stick backup
# Alternative to restore-ssh-from-dashlane.sh for offline recovery

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

echo ""
info "SSH Key Restoration from USB Stick"
echo ""

# Check if USB is mounted
info "Looking for mounted USB devices..."
USB_MOUNTS=$(lsblk -o NAME,MOUNTPOINT,LABEL,SIZE,TYPE | grep -E "sd[a-z][0-9].*/" | grep -v "/$" || true)

if [ -z "$USB_MOUNTS" ]; then
  warning "No USB devices appear to be mounted"
  echo ""
  echo "Available block devices:"
  lsblk -o NAME,MOUNTPOINT,LABEL,SIZE,TYPE
  echo ""
  info "To mount a USB stick:"
  echo "  1. Insert USB stick"
  echo "  2. Find device: lsblk"
  echo "  3. Mount: udisksctl mount -b /dev/sdX1"
  exit 1
fi

echo ""
echo "Mounted USB devices:"
echo "$USB_MOUNTS"
echo ""

# Prompt for USB mount path
read -p "Enter the mount point of your USB (e.g., /run/media/$USER/USBNAME): " USB_PATH

# Validate path exists
if [ ! -d "$USB_PATH" ]; then
  error "Directory $USB_PATH does not exist"
fi

# Look for .ssh folder on USB
if [ ! -d "$USB_PATH/.ssh" ]; then
  error "No .ssh folder found at $USB_PATH/.ssh"
fi

info "Found .ssh folder on USB"

# Show what will be copied
echo ""
echo "SSH keys found on USB:"
ls -lh "$USB_PATH/.ssh/"
echo ""

# Confirm before proceeding
warning "This will replace your current ~/.ssh directory"
read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  info "Cancelled by user"
  exit 0
fi

# Backup existing .ssh if it exists
if [ -d "$HOME/.ssh" ]; then
  BACKUP_NAME="$HOME/.ssh.backup.$(date +%Y%m%d_%H%M%S)"
  info "Backing up existing .ssh to $BACKUP_NAME"
  mv "$HOME/.ssh" "$BACKUP_NAME"
fi

# Create .ssh directory
mkdir -p "$HOME/.ssh"

# Copy all files from USB
info "Copying SSH keys from USB..."
cp -r "$USB_PATH/.ssh/"* "$HOME/.ssh/"

# Set correct permissions
info "Setting correct permissions..."
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/id_ed25519" 2>/dev/null || true
chmod 644 "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
chmod 600 "$HOME/.ssh/id_rsa" 2>/dev/null || true
chmod 644 "$HOME/.ssh/id_rsa.pub" 2>/dev/null || true
chmod 644 "$HOME/.ssh/known_hosts" 2>/dev/null || true
chmod 644 "$HOME/.ssh/config" 2>/dev/null || true

success "SSH keys restored from USB"

# List what was copied
echo ""
info "Files in ~/.ssh:"
ls -lh "$HOME/.ssh/"

# Test SSH connection to newton.local if key exists
if [ -f "$HOME/.ssh/id_ed25519" ]; then
  echo ""
  info "Testing SSH connection to newton.local..."
  if ssh -o BatchMode=yes -o ConnectTimeout=5 roger@newton.local exit 2>/dev/null; then
    success "SSH connection to newton.local successful!"
  else
    warning "SSH connection to newton.local failed"
    echo "  This is normal if:"
    echo "  - newton.local is not currently reachable"
    echo "  - The key needs to be added to newton.local authorized_keys"
    echo ""
    echo "  To authorize this key on newton.local (if password auth enabled):"
    echo "    ssh-copy-id roger@newton.local"
  fi
fi

echo ""
success "Done! You can now unmount your USB stick"
info "To unmount: udisksctl unmount -b /dev/sdX1"
echo ""
