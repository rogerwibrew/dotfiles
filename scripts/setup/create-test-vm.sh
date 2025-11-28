#!/bin/bash
# Create a test VM for dotfiles testing
# This script guides you through creating an Arch Linux VM

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
info "Arch Linux Test VM Creation Guide"
echo ""

# Check if libvirt is running
if ! systemctl is-active --quiet libvirtd; then
  error "libvirtd is not running. Run setup-vm-testing.sh first"
fi

# Check if user is in libvirt group
if ! groups | grep -q libvirt; then
  error "User is not in 'libvirt' group. Log out and back in after running setup-vm-testing.sh"
fi

# Check for Arch ISO
ISO_DIR="$HOME/downloads"
LATEST_ISO=$(find "$ISO_DIR" -name "archlinux-*.iso" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

if [ -z "$LATEST_ISO" ]; then
  warning "No Arch ISO found in $ISO_DIR"
  echo ""
  info "Downloading latest Arch ISO..."
  mkdir -p "$ISO_DIR"
  cd "$ISO_DIR"

  # Get latest ISO URL
  MIRROR="https://mirror.rackspace.com/archlinux/iso/latest"
  ISO_NAME="archlinux-x86_64.iso"

  info "Downloading from $MIRROR/$ISO_NAME"
  curl -L -o "$ISO_DIR/$ISO_NAME" "$MIRROR/$ISO_NAME"

  LATEST_ISO="$ISO_DIR/$ISO_NAME"
  success "ISO downloaded to $LATEST_ISO"
else
  success "Found Arch ISO: $LATEST_ISO"
fi

echo ""
info "VM Configuration"
echo ""

# VM parameters
VM_NAME="arch-dotfiles-test"
VM_RAM=4096  # 4GB
VM_CPUS=2
VM_DISK_SIZE=20  # 20GB

echo "VM Name:       $VM_NAME"
echo "RAM:           ${VM_RAM}MB (4GB)"
echo "CPUs:          $VM_CPUS"
echo "Disk Size:     ${VM_DISK_SIZE}GB"
echo "ISO:           $LATEST_ISO"
echo ""

read -p "Create VM with these settings? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  info "Cancelled by user"
  exit 0
fi

# Check if VM already exists
if virsh list --all | grep -q "$VM_NAME"; then
  warning "VM '$VM_NAME' already exists"
  read -p "Delete and recreate? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    info "Destroying existing VM..."
    virsh destroy "$VM_NAME" 2>/dev/null || true
    virsh undefine "$VM_NAME" --remove-all-storage 2>/dev/null || true
    success "Existing VM removed"
  else
    info "Cancelled by user"
    exit 0
  fi
fi

# Create VM using virt-install
info "Creating VM '$VM_NAME'..."

virt-install \
  --name "$VM_NAME" \
  --ram "$VM_RAM" \
  --vcpus "$VM_CPUS" \
  --disk size="$VM_DISK_SIZE" \
  --cdrom "$LATEST_ISO" \
  --os-variant archlinux \
  --network network=default \
  --graphics spice \
  --virt-type kvm \
  --noautoconsole

success "VM '$VM_NAME' created successfully!"

echo ""
info "VM Management:"
echo "  Open virt-manager:    virt-manager"
echo "  Start VM:             virsh start $VM_NAME"
echo "  Connect to console:   virt-viewer $VM_NAME"
echo "  Stop VM:              virsh shutdown $VM_NAME"
echo "  Force stop:           virsh destroy $VM_NAME"
echo "  Delete VM:            virsh undefine $VM_NAME --remove-all-storage"
echo ""

info "Testing Your Dotfiles:"
echo "  1. Open virt-manager or run: virt-viewer $VM_NAME"
echo "  2. Install Arch Linux (follow ArchWiki installation guide)"
echo "  3. During install, create user 'roger' and set hostname to 'kelvin' or 'watt'"
echo "  4. After install, clone your dotfiles:"
echo "     git clone /path/to/dotfiles ~/dotfiles"
echo "  5. Run bootstrap script:"
echo "     cd ~/dotfiles && ./bootstrap.sh"
echo "  6. Test your configuration!"
echo ""

info "Quick Arch Install Tips:"
echo "  - Set keyboard:      loadkeys us"
echo "  - Connect to wifi:   iwctl"
echo "  - Partition disk:    cfdisk /dev/vda"
echo "  - Install base:      pacstrap /mnt base linux linux-firmware"
echo "  - Install bootloader: GRUB or systemd-boot"
echo "  - Create user roger: useradd -m -G wheel roger"
echo "  - Enable sudo:       visudo (uncomment %wheel)"
echo ""

read -p "Open virt-manager now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  virt-manager &
  disown
  success "virt-manager launched"
fi

echo ""
success "Setup complete!"
echo ""
