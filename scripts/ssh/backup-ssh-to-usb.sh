#!/bin/bash
# Backup SSH keys to USB stick
# Run this periodically to keep an offline backup of your SSH keys

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
info "SSH Key Backup to USB Stick"
echo ""

# Check if .ssh directory exists
if [ ! -d "$HOME/.ssh" ]; then
  error "No .ssh directory found at $HOME/.ssh"
fi

# Show what will be backed up
echo "SSH keys to backup:"
ls -lh "$HOME/.ssh/"
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

# Check if writable
if [ ! -w "$USB_PATH" ]; then
  error "USB path $USB_PATH is not writable"
fi

# Warn if .ssh already exists on USB
if [ -d "$USB_PATH/.ssh" ]; then
  warning "Existing .ssh folder found on USB"
  read -p "Overwrite existing backup? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    info "Cancelled by user"
    exit 0
  fi
  rm -rf "$USB_PATH/.ssh"
fi

# Copy .ssh to USB
info "Copying SSH keys to USB..."
cp -r "$HOME/.ssh" "$USB_PATH/"

# Verify backup
if [ -d "$USB_PATH/.ssh" ]; then
  success "SSH keys backed up successfully"
  echo ""
  info "Backup contents:"
  ls -lh "$USB_PATH/.ssh/"
  echo ""
  success "Done! Keep this USB stick in a secure location"
  echo ""
  info "To restore on a new system:"
  echo "  ~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh"
else
  error "Backup failed - .ssh directory not found on USB"
fi

echo ""
info "You can now safely unmount your USB stick"
info "To unmount: udisksctl unmount -b /dev/sdX1"
echo ""
