# Dotfiles - Ubuntu + dwm

**Branch**: `ubuntu-dwm`

This dotfiles setup prioritizes **stability and simplicity** over aesthetics.
It uses Ubuntu LTS with dwm (suckless window manager) on X11 for maximum
hardware compatibility and minimal maintenance.

## Philosophy

After using Hyprland on Arch, I wanted something more stable with better
hardware driver support (nvidia, Alienware-specific). This setup is:

1. **Rock-solid stable**: Ubuntu LTS, no rolling releases
2. **Minimal**: dwm on X11, no compositor, no visual effects
3. **Terminal-first**: Everything possible done in terminal/TUI
4. **Fast**: Modern Rust CLI tools replacing standard Unix utilities
5. **Reproducible**: Single bootstrap script for fresh installs

## Quick Start

On a fresh Ubuntu 22.04+ install:

```bash
git clone git@github.com:rogerwibrew/dotfiles.git ~/dotfiles
cd ~/dotfiles
git checkout ubuntu-dwm
./bootstrap-ubuntu-dwm.sh
```

The bootstrap script will:

- Install all packages via apt
- Setup Flatpak and install Chromium, Steam
- Install Rust and modern CLI tools (eza, bat, fd, ripgrep, etc.)
- Compile suckless tools (dwm, dmenu, slstatus)
- Install Claude Code, nvm, Node.js LTS
- Symlink all configurations
- Setup LazyVim for Neovim

After bootstrap completes:

1. Restore SSH key from USB: `~/scripts/ssh/restore-ssh-from-usb.sh`
2. Log out and log back in (or reboot)
3. Start X with: `startx`
4. dwm will launch automatically

## System Requirements

- **User**: roger
- **Hostname**: newton, kelvin, or watt
- **OS**: Ubuntu 22.04+ (LTS)

The bootstrap script will verify these requirements before proceeding.

## Features

- **WM**: dwm (suckless dynamic window manager)
- **Display**: X11 (Xorg), no compositor
- **Shell**: zsh with syntax highlighting, auto-completion, and vi mode
- **Terminal**: Kitty with ligature support
- **Editor**: Neovim with LazyVim
- **File Manager**: yazi (terminal-based)
- **Launcher**: dmenu (suckless)
- **Status Bar**: slstatus (suckless)
- **Lock Screen**: slock (suckless)
- **Notifications**: dunst
- **Browser**: Chromium (Flatpak)
- **Sync**: Unison with continuous file watching
- **Session Manager**: tmux with minimal theme
- **Rust CLI Tools**: eza, bat, fd, ripgrep, dust, procs, bottom, zoxide

## Machine-Specific Configurations

### newton (Desktop - 32" 4K)

- Monitor: 3840x2160, 144 DPI (1.5x scaling)
- Network: Wired (enp4s0)
- Config: `.Xresources-newton`, `slstatus/config-newton.h`

### watt (Laptop - HiDPI)

- Monitor: 4K display, 192 DPI (2x scaling)
- Battery: Battery indicator in slstatus
- Keyboard: GB layout
- Config: `.Xresources-watt`, `slstatus/config-watt.h`

### kelvin (Desktop - Standard DPI)

- Monitor: Standard display, 96 DPI (1x scaling)
- Network: Wired
- Config: `.Xresources-kelvin`, `slstatus/config-kelvin.h`

## dwm Keybindings

All keybindings use Super (Mod4) as the modifier key.

### Applications

- `Super + Shift + Return` - Terminal (Kitty)
- `Super + d` - Application launcher (dmenu)
- `Super + w` - Close window
- `Super + Shift + q` - Quit dwm
- `Super + Ctrl + l` - Lock screen (slock)

### Window Management (Master/Stack Layout)

- `Super + j` - Focus next window
- `Super + k` - Focus previous window
- `Super + Return` - Swap current window to master
- `Super + h` - Shrink master area
- `Super + l` - Grow master area
- `Super + i` - Increment number of masters
- `Super + d` - Decrement number of masters

### Layouts

- `Super + t` - Tiled layout (master/stack)
- `Super + f` - Monocle layout (fullscreen)
- `Super + Space` - Toggle floating window

### Workspaces (Tags)

- `Super + 1-9` - Switch to workspace 1-9
- `Super + Shift + 1-9` - Move window to workspace 1-9
- `Super + 0` - View all workspaces
- `Super + Tab` - Toggle between last two workspaces

## Rust CLI Tools

Modern replacements for standard Unix tools, aliased transparently:

| Tool | Replaces | Alias |
|------|----------|-------|
| eza | ls | `alias ls='eza'` |
| bat | cat | `alias cat='bat'` |
| fd | find | `alias find='fd'` |
| ripgrep | grep | `alias grep='rg'` |
| dust | du | `alias du='dust'` |
| procs | ps | `alias ps='procs'` |
| bottom | top/htop | `alias top='btm'` |
| zoxide | cd | `eval "$(zoxide init zsh)"` |
| delta | diff | `alias diff='delta'` |

Original commands still accessible with 'o' prefix: `ols`, `ocat`, `ofind`,
etc.

## File Synchronization

Unison syncs `~/dev` and `~/data` folders between machines automatically:

```bash
ssh-newton       # Connect to newton
sync-now         # Manual one-time sync
sync-check       # Attach to sync tmux session
sync-stop        # Stop continuous sync
sync-log         # Watch sync log in real-time
```

Unison runs in a tmux session named "unison" on login, syncing continuously
with file watching enabled.

## Directory Structure

```
~/
├── dev/          # Development projects (synced)
├── data/         # Personal data, documents (synced)
└── downloads/    # Downloaded files
```

XDG Base Directory compliance keeps home clean:

```
~/.config/        # Configuration files (XDG_CONFIG_HOME)
~/.local/share/   # Application data (XDG_DATA_HOME)
~/.cache/         # Temporary cache (XDG_CACHE_HOME)
```

## Customizing dwm

dwm is configured by editing source code and recompiling:

```bash
# Edit dwm config
cd ~/dotfiles/suckless/dwm
vim config.h

# Recompile and install
sudo make clean install

# Restart dwm: Mod+Shift+Q, then login again
```

Same process applies to dmenu and slstatus.

## System Maintenance

```bash
# Update system
sudo apt update && sudo apt upgrade

# Update Flatpak apps
flatpak update

# Update Rust tools
cargo install-update -a  # Requires cargo-update
```

## Post-Install Steps

1. Restore SSH keys from USB: `~/scripts/ssh/restore-ssh-from-usb.sh`
2. Run first-time Unison sync: `~/scripts/sync/first-sync.sh`
3. Log out and log back in
4. Start X with: `startx`
5. Open Neovim - LazyVim will auto-install plugins (run `:LazyHealth` to
   verify)

## Notes

**Hardware Compatibility**: This setup uses Ubuntu LTS specifically for
better driver support on Alienware hardware. Debian was considered but
avoided due to potential driver issues.

**AI Assistance**: Scripts written with Claude Code. Tested on my machines
but may be fragile - review before using on your system.

**Personalization**: This is highly customized for my workflow. Machine
names (newton, watt, kelvin) are hardcoded. Adapt to your setup as needed.

## Other Branches

- `main`: Arch Linux + Hyprland (Wayland, beautiful but more complex)
- `debian-dwm`: Debian Stable + dwm (even more stable, untested on my
  hardware)
- `ubuntu-sway`: Ubuntu + Sway (Wayland alternative, experimental)

## License

Personal dotfiles - use at your own discretion.
