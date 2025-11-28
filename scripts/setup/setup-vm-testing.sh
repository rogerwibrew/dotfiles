#!/bin/bash
# Setup QEMU/KVM virtualization for testing dotfiles on fresh Arch install
# This script installs and configures libvirt/virt-manager for VM testing

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
info "QEMU/KVM Virtualization Setup"
echo ""

# Check if running on Arch
if [ ! -f /etc/arch-release ]; then
  error "This script is designed for Arch Linux only"
fi

# Check for virtualization support
info "Checking CPU virtualization support..."
if grep -E 'vmx|svm' /proc/cpuinfo > /dev/null; then
  success "CPU supports virtualization"
else
  error "CPU does not support virtualization (VT-x/AMD-V required)"
fi

# Install required packages
info "Installing QEMU/KVM packages..."
sudo pacman -S --needed --noconfirm \
  qemu-full \
  libvirt \
  virt-manager \
  ebtables \
  dnsmasq \
  bridge-utils \
  vde2

success "Packages installed"

# Add user to libvirt group
info "Adding user to 'libvirt' group..."
sudo usermod -a -G libvirt "$(whoami)"
success "User added to libvirt group (requires logout to take effect)"

# Enable and start libvirtd service
info "Enabling libvirtd service..."
sudo systemctl enable --now libvirtd.service
success "libvirtd service enabled and started"

# Enable default network
info "Configuring default network..."
sudo virsh net-autostart default 2>/dev/null || true
sudo virsh net-start default 2>/dev/null || true
success "Default network configured"

# Check status
echo ""
info "Virtualization Status:"
systemctl status libvirtd.service --no-pager | head -5
echo ""

success "QEMU/KVM setup complete!"
echo ""
warning "IMPORTANT: You must log out and log back in for group changes to take effect"
echo ""
info "Next steps:"
echo "  1. Log out and log back in"
echo "  2. Download Arch ISO:"
echo "     curl -O https://mirror.rackspace.com/archlinux/iso/latest/archlinux-x86_64.iso"
echo "  3. Launch virt-manager and create a new VM"
echo "  4. Or use the helper script:"
echo "     ~/dotfiles/scripts/setup/create-test-vm.sh"
echo ""
