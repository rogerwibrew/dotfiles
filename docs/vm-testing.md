# VM Testing Guide

This guide helps you test your dotfiles on a fresh Arch Linux installation
using QEMU/KVM virtualization.

## Initial Setup (One-Time)

Run the setup script to install and configure virtualization:

```bash
~/dotfiles/scripts/setup/setup-vm-testing.sh
```

This installs:
- QEMU/KVM (virtualization)
- libvirt (VM management)
- virt-manager (GUI)
- Network tools (dnsmasq, ebtables, bridge-utils)

**Important**: Log out and back in after running this script for group
changes to take effect.

## Creating a Test VM

Run the guided VM creation script:

```bash
~/dotfiles/scripts/setup/create-test-vm.sh
```

This will:
1. Download latest Arch ISO (if needed)
2. Create a VM with sensible defaults (4GB RAM, 2 CPUs, 20GB disk)
3. Launch the VM ready for Arch installation

## VM Management Commands

```bash
# Open VM manager GUI
virt-manager

# Start VM
virsh start arch-dotfiles-test

# Connect to VM console
virt-viewer arch-dotfiles-test

# Shutdown VM
virsh shutdown arch-dotfiles-test

# Force stop VM
virsh destroy arch-dotfiles-test

# Delete VM completely
virsh undefine arch-dotfiles-test --remove-all-storage

# List all VMs
virsh list --all

# Take a snapshot (before testing dotfiles)
virsh snapshot-create-as arch-dotfiles-test \
  before-dotfiles "Before running bootstrap"

# Restore snapshot
virsh snapshot-revert arch-dotfiles-test before-dotfiles

# List snapshots
virsh snapshot-list arch-dotfiles-test
```

## Testing Workflow

### 1. Install Arch in VM

Follow the standard Arch installation process:

```bash
# Set keyboard layout
loadkeys us

# Connect to network (if needed for wifi)
iwctl

# Partition disk
cfdisk /dev/vda
# Create: 512MB EFI partition, rest as root partition

# Format partitions
mkfs.fat -F32 /dev/vda1
mkfs.ext4 /dev/vda2

# Mount
mount /dev/vda2 /mnt
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot

# Install base system
pacstrap /mnt base linux linux-firmware base-devel git sudo \
  grub efibootmgr networkmanager

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt

# Set timezone
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

# Generate locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname (kelvin or watt)
echo "kelvin" > /etc/hostname

# Set root password
passwd

# Create user roger
useradd -m -G wheel roger
passwd roger

# Enable sudo for wheel group
EDITOR=vim visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL

# Install bootloader
grub-install --target=x86_64-efi --efi-directory=/boot \
  --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Enable NetworkManager
systemctl enable NetworkManager

# Exit and reboot
exit
umount -R /mnt
reboot
```

### 2. Clone and Test Dotfiles

After Arch installation, log in as roger:

```bash
# Clone dotfiles (adjust path as needed)
git clone https://github.com/yourusername/dotfiles ~/dotfiles

# Or, if testing local changes, use git daemon or python server
# On host: cd ~/dev/dotfiles && python -m http.server 8000
# In VM: wget http://192.168.122.1:8000/archive.tar.gz

# Run bootstrap script
cd ~/dotfiles
./bootstrap.sh

# Follow on-screen instructions
# Restore SSH keys (use USB method in VM or skip)
# Reboot and select Hyprland from display manager
```

### 3. Snapshot Strategy

Take snapshots at key points for easy rollback:

```bash
# After fresh Arch install (before dotfiles)
virsh snapshot-create-as arch-dotfiles-test fresh-arch \
  "Fresh Arch install, ready for dotfiles"

# After bootstrap (before customization)
virsh snapshot-create-as arch-dotfiles-test post-bootstrap \
  "After running bootstrap.sh"

# Restore to any snapshot
virsh snapshot-revert arch-dotfiles-test fresh-arch
```

## Sharing Files Between Host and VM

### Option 1: Simple HTTP Server (Easiest)

On host:
```bash
cd ~/dev/dotfiles
python -m http.server 8000
```

In VM:
```bash
# Host IP is typically 192.168.122.1 on default libvirt network
curl http://192.168.122.1:8000/bootstrap.sh
```

### Option 2: Git Daemon

On host:
```bash
cd ~/dev/dotfiles
git daemon --base-path=. --export-all --reuseaddr --verbose
```

In VM:
```bash
git clone git://192.168.122.1/ ~/dotfiles
```

### Option 3: Shared Folder (Advanced)

Edit VM configuration in virt-manager to add a shared filesystem.

## Troubleshooting

### VM won't start - KVM not available

Check virtualization is enabled in BIOS/UEFI.

```bash
# Check if KVM module is loaded
lsmod | grep kvm
```

### Network not working in VM

```bash
# On host, ensure default network is active
sudo virsh net-start default
sudo virsh net-autostart default

# In VM, enable NetworkManager
sudo systemctl enable --now NetworkManager
```

### Can't connect to VM console

```bash
# Install virt-viewer if missing
sudo pacman -S virt-viewer

# Or use virt-manager GUI
virt-manager
```

### Permission denied errors

Ensure you're in the libvirt group and logged out/in:

```bash
groups | grep libvirt
```

## Performance Tips

- Allocate at least 4GB RAM for smooth Hyprland testing
- Use 2+ CPUs for faster package installation
- Enable KVM acceleration (should be automatic)
- Consider using qcow2 disk format with compression for space efficiency

## Quick Reference

```bash
# Full workflow
~/dotfiles/scripts/setup/setup-vm-testing.sh  # One-time setup
# Log out and log back in
~/dotfiles/scripts/setup/create-test-vm.sh    # Create VM
# Install Arch in VM
# Clone dotfiles and run bootstrap.sh
# Test your configuration
# Take snapshots, iterate, improve
```
