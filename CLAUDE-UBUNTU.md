# CLAUDE-UBUNTU.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository's **Ubuntu + Sway branch**.

**IMPORTANT**: This is the `ubuntu-sway` branch. For the original Arch
Linux + Hyprland setup, see the `main` branch and `CLAUDE.md`.

## Project Overview

This repository contains a complete, reproducible dotfiles system for
Ubuntu with Sway WM. The core concept: clone this repo on a fresh Ubuntu
install, run the bootstrap script, and have a fully functional window
manager with all configurations, scripts, and tools ready to use.

Goals:

- **Beautiful but simple**: Clean aesthetics without unnecessary complexity
- **Terminal-first**: If it can be done in the terminal, do it there
- **Minimal GUI**: Only browser and PDF viewer as GUI applications
- **Fully reproducible**: Everything needed is tracked in this repository
- **Stable and boring**: Sway is mature, stable, i3-compatible

## Guiding Principles

- **Wayland-native**: Using Sway compositor and Wayland ecosystem
- **Version controlled**: All configs, scripts, and package lists in git
- **Bootstrap-ready**: Single script deployment on fresh Ubuntu install
- **XDG compliant**: Following XDG Base Directory Specification for clean
  home directory
- **Ubuntu LTS**: Target Ubuntu 24.04 LTS for long-term stability

## Technology Stack

### Core Components

- **OS**: Ubuntu 24.04 LTS (Noble Numbat)
- **Compositor**: Sway (i3-compatible Wayland compositor)
- **Shell**: zsh with syntax highlighting, vi mode, and auto-completion
- **Text Editor**: Neovim with LazyVim
- **Terminal**: Kitty with ligature support
- **Browser**: Chromium or Firefox
- **PDF Viewer**: Zathura
- **Scanner**: simple-scan
- **File Manager**: yazi (terminal-based)

### Wayland Ecosystem Tools

- **Status Bar**: Waybar with Tokyo Night theme
- **Launcher**: wofi
- **Lock Screen**: swaylock
- **Idle Management**: swayidle (5 min idle → lock, 10 min → screen off)
- **Notifications**: mako
- **Screenshots**: grim + slurp
- **Clipboard**: wl-clipboard + cliphist
- **Wallpaper**: swaybg (Sway's built-in background manager)

### Development and Sync

- **Session Manager**: tmux with Tokyo Night theme
- **Sync Tool**: Unison with continuous file watching
- **Server**: newton.local (SSH with ed25519 keys, Avahi mDNS)
- **Synced Folders**: ~/dev and ~/data
- **Version Control**: git

## Core Architecture

### Configuration Deployment System

The dotfiles use **direct symlinking** (not GNU stow) via
bootstrap-ubuntu.sh:

- Configs live in `~/dotfiles/.config/`
- Bootstrap creates symlinks: `~/.config/sway` → `~/dotfiles/.config/sway`
- Idempotent: Safe to run bootstrap-ubuntu.sh multiple times
- Hostname detection at runtime chooses kelvin vs watt configs
- See bootstrap-ubuntu.sh:1-18 for detailed execution order

After bootstrap, editing files in `~/dotfiles/.config/` directly updates
the active configuration (no re-bootstrap needed).

### Hostname-Specific Configuration Pattern

Two-layer config system for desktop vs laptop:

- **Base configs**: `.config/sway/config` (reference/fallback)
- **Host-specific**: `.config/sway/config.d/kelvin.conf`,
  `watt.conf`
- **Runtime selection**: Bootstrap symlinks correct config based on
  `$(hostname)`
- **Waybar**: Separate `config-kelvin` and `config-watt` for
  battery/scaling differences

Key differences:

- **kelvin** (desktop): 1.666667x scaling, no battery indicator
- **watt** (laptop): 2.5x scaling (4K display), battery indicator,
  GB keyboard layout

### XDG Base Directory Compliance

Clean home directory via `.zprofile` environment variables:

- `XDG_CONFIG_HOME=~/.config` - All application configs
- `XDG_DATA_HOME=~/.local/share` - Application data (nvm, cargo, etc)
- `XDG_CACHE_HOME=~/.cache` - Temporary data (zsh history, python history)

Forces XDG compliance for: zsh, python, cargo, go, nvm, npm, gnupg,
gradle, wget.

Result: Clean `~/` with only `dev/`, `data/`, `downloads/` directories.

### Unison Bidirectional Sync Architecture

Continuous real-time sync to newton.local server:

- **Auto-start**: `start-unison.sh` called from .zshrc on login
- **Dual sync**: Both `~/dev` and `~/data` folders synced independently
- **Tmux session**: Named "unison" with two panes (dev-sync, data-sync)
- **File watching**: `repeat = watch` mode in Unison profiles
- **Conflict resolution**: Auto-resolve via `prefer = newer`
- **Profiles**: `.config/unison/dev-sync.prf` and `data-sync.prf`
- **Logging**: Separate logs in `~/.unison/*.log`

Dependencies: SSH key authentication (ed25519), Avahi mDNS for .local
hostname resolution.

Ignore patterns: .git, node_modules, __pycache__, .venv, build, dist,
target, *.swp

## Sway vs Hyprland: Key Differences

### Configuration Syntax

**Sway** uses i3-compatible syntax:
- Config file: `~/.config/sway/config`
- Keybindings: `bindsym $mod+Shift+Return exec kitty`
- Window rules: `for_window [class="Firefox"] move to workspace 2`
- No animations by default (stable, minimal)

**Hyprland** (in `main` branch) uses its own syntax:
- Config file: `~/.config/hypr/hyprland.conf`
- Keybindings: `bind = $mainMod SHIFT, Return, exec, kitty`
- Animations and eye candy built-in

### Tiling Behavior

**Sway**: i3-style manual tiling
- Windows split horizontally/vertically based on layout
- No "master" layout by default
- Tabbed and stacked layouts available
- More manual control over window placement

**Hyprland**: Master layout + dwindle
- Master window with stack of other windows
- Automatic window arrangement
- More like xmonad/dwm

### Stability

**Sway**: Rock-solid, mature, stable
- Part of official Ubuntu repos
- Widely tested
- Fewer bugs
- "Boring but reliable"

**Hyprland**: Cutting-edge, feature-rich
- More visual effects
- More active development
- Occasionally breaking changes
- "Exciting but less stable"

## Common Development Commands

### Bootstrap and Testing

```bash
# Fresh install deployment (idempotent, safe to run multiple times)
cd ~/dotfiles
./bootstrap-ubuntu.sh

# Test bootstrap on VM (requires virt-manager)
./scripts/setup/create-test-vm-ubuntu.sh
./scripts/setup/setup-vm-testing-ubuntu.sh
```

### Dotfiles Management

```bash
# Push changes to git (via helper script)
~/dotfiles/scripts/git/dotfiles-push.sh
# Or use alias: dotfiles-push

# Pull and re-deploy configs
~/dotfiles/scripts/git/dotfiles-pull.sh
./bootstrap-ubuntu.sh

# After editing configs in ~/dotfiles/.config/, changes are live
# (symlinks auto-update, no re-bootstrap needed)

# Switch between Arch and Ubuntu branches
git checkout main              # Arch + Hyprland
git checkout ubuntu-sway       # Ubuntu + Sway
```

### SSH and Sync Management

```bash
# Initial SSH setup (first time only on new machine)
~/dotfiles/scripts/ssh/restore-ssh-from-dashlane.sh
# OR from USB backup
~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh

# Verify SSH key setup
ssh roger@newton.local

# Sync commands (via aliases in .config/shell/alias)
ssh-newton              # Connect to newton.local
sync-now               # Manual one-time sync (both dev and data)
sync-check             # Attach to tmux unison session
sync-stop              # Kill tmux unison session
sync-log               # Tail -f dev-sync.log
```

### Package Management

```bash
# Update all packages
sudo apt update && sudo apt upgrade

# Install new package and track it
sudo apt install package-name
echo "package-name" >> ~/dotfiles/packages-ubuntu.txt

# Reinstall from packages-ubuntu.txt (bootstrap does this automatically)
sudo apt install $(grep -v '^#' packages-ubuntu.txt | grep -v '^$')

# Snap packages (for some applications)
snap install package-name

# PPAs (for newer software versions)
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
```

### Web Application Management

```bash
# Install all webapps from webapps.txt (bootstrap does this)
~/dotfiles/scripts/setup/install-webapps.sh

# Add new webapp interactively
~/dotfiles/scripts/webapp/install-webapp.sh

# Remove webapp interactively
~/dotfiles/scripts/webapp/remove-webapp.sh

# Add webapp to dotfiles for bootstrap
# 1. Add line to webapps/webapps.txt: NAME|URL|icon.svg
# 2. Place icon in webapps/icons/ (optional)
# 3. Commit to repo
```

### Sway and Waybar

```bash
# Reload Sway config
swaymsg reload

# Test specific command
swaymsg exec kitty

# Restart waybar (if making changes)
pkill waybar && waybar &

# Check current Sway config being used
swaymsg -t get_config

# List all outputs (monitors)
swaymsg -t get_outputs

# List all workspaces
swaymsg -t get_workspaces
```

## Bootstrap Script Workflow

Understanding `bootstrap-ubuntu.sh` execution:

1. **System validation**: Check Ubuntu version, user 'roger', set
   SCRIPT_DIR
2. **Add PPAs**: Neovim, other software requiring newer versions
3. **System update**: `sudo apt update && sudo apt upgrade`
4. **Package installation**: Parse `packages-ubuntu.txt`, install via apt
5. **Snap packages**: Install packages only available via snap
6. **External tools**: Dashlane CLI, Claude Code, nvm, Node.js LTS
7. **Directory creation**: `~/dev`, `~/data`, `~/downloads`,
   `.local/share/wallpapers`
8. **Symlink configs**: `.config/*`, `.zprofile`, `.zshenv` → dotfiles
   repo
9. **Install webapps**: Parse `webapps/webapps.txt`, install desktop
   entries and icons
10. **Display Manager setup**: GDM or LightDM with Sway session
11. **mDNS configuration**: Auto-edit `/etc/nsswitch.conf` for .local
    resolution
12. **Enable services**: sshd, avahi-daemon, bluetooth, cups
13. **Shell setup**: Change default shell to zsh via chsh

**Idempotency**: Safe to run multiple times; checks before
installing/symlinking.

**CRITICAL**: SCRIPT_DIR is set early before any `cd` commands to ensure
correct paths throughout execution.

## Repository Structure

```
.
├── .config/
│   ├── sway/                  # Sway configuration
│   │   ├── config             # Main Sway config
│   │   ├── config.d/          # Modular configs
│   │   │   ├── kelvin.conf    # Desktop-specific
│   │   │   ├── watt.conf      # Laptop-specific
│   │   │   └── autostart.conf # Startup applications
│   │   └── wallpaper.conf     # Wallpaper config
│   ├── zsh/
│   │   └── .zshrc             # Interactive shell config
│   ├── shell/
│   │   └── alias              # Shell aliases (modular)
│   ├── waybar/                # Status bar config
│   │   ├── config-kelvin      # Desktop waybar
│   │   ├── config-watt        # Laptop waybar
│   │   └── style.css          # Tokyo Night styling
│   ├── unison/                # Sync profiles
│   │   ├── dev-sync.prf       # ~/dev sync config
│   │   └── data-sync.prf      # ~/data sync config
│   ├── kitty/                 # Terminal configuration
│   ├── wofi/                  # App launcher styling
│   ├── mako/                  # Notification daemon config
│   ├── swaylock/              # Lock screen config
│   ├── swayidle/              # Idle management config
│   └── tmux/                  # Terminal multiplexer config
├── scripts/
│   ├── power/                 # powermenu.sh (shutdown, reboot, suspend)
│   ├── ssh/                   # SSH setup and restore scripts
│   ├── sync/                  # Unison sync management scripts
│   ├── system/                # System maintenance scripts
│   ├── screenshot/            # Screenshot utilities (grim + slurp)
│   ├── git/                   # Dotfiles git helpers
│   ├── setup/                 # Installation scripts
│   ├── tui/                   # TUI app launcher
│   ├── webapp/                # Web app installation
│   ├── volume-notify.sh       # Volume change notifications
│   └── brightness-notify.sh   # Brightness notifications
├── wallpapers/                # Custom wallpapers
├── webapps/                   # Web application definitions
│   ├── icons/                 # Webapp icons (svg format)
│   └── webapps.txt            # Webapp list (NAME|URL|ICON_FILE)
├── docs/                      # Additional documentation
├── .zprofile                  # Login shell, XDG environment variables
├── .zshenv                    # Zsh environment (sources .zprofile)
├── packages-ubuntu.txt        # Ubuntu package list (apt)
├── bootstrap-ubuntu.sh        # Ubuntu installation script
├── README-UBUNTU.md           # Ubuntu-specific documentation
├── CLAUDE-UBUNTU.md           # This file
└── CLAUDE.md                  # Arch Linux version (main branch)
```

## Technical Preferences

- **Package Management**: Use apt for official packages, snap for GUI apps,
  build from source when necessary
- **Shell**: Bash for scripts (not zsh/fish for simplicity and portability)
- **Configuration Format**: Native formats (no complex templating)
- **Dependencies**: Minimize external dependencies where possible
- **Documentation**: In-line comments in configs, README for user-facing
  setup instructions
- **Paths**: Use environment variables ($HOME, $XDG_CONFIG_HOME, etc.)
  never hardcode paths
- **Testing**: Use VM testing scripts before deploying major changes

## Sway Configuration Structure

Sway uses i3-compatible configuration syntax. Key concepts:

### Variables
```
set $mod Mod4
set $term kitty
set $menu wofi --show drun
```

### Keybindings
```
# Basic format: bindsym [modifiers+]key command

# Application shortcuts
bindsym $mod+Shift+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill

# Layout manipulation
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+Shift+1 move container to workspace number 1
```

### Window Rules
```
# for_window [criteria] command

for_window [app_id="firefox"] move to workspace 2
for_window [class="steam"] floating enable
for_window [title="Picture-in-Picture"] floating enable, sticky enable
```

### Output Configuration
```
# output <name> resolution <WIDTHxHEIGHT> position <X,Y> scale <factor>

output eDP-1 resolution 3840x2160 position 0,0 scale 2.5
output HDMI-A-1 resolution 1920x1080 position 1536,0 scale 1
```

### Input Configuration
```
input "type:keyboard" {
    xkb_layout gb
    xkb_options ctrl:nocaps
}

input "type:touchpad" {
    tap enabled
    natural_scroll enabled
}
```

## Color Scheme

**Tokyo Night** - Use this as the base theme across all components for
visual consistency.

### Tokyo Night Color Palette

- Background: `#1a1b26`
- Foreground: `#c0caf5`
- Black: `#15161e`
- Red: `#f7768e`
- Green: `#9ece6a`
- Yellow: `#e0af68`
- Blue: `#7aa2f7`
- Magenta: `#bb9af7`
- Cyan: `#7dcfff`
- White: `#a9b1d6`
- Bright variants available for accents

Reference: Waybar, Kitty, Sway, display manager all use this palette.

### Sway Colors
```
# class                 border  backgr  text    indicator child_border
client.focused          #7aa2f7 #7aa2f7 #1a1b26 #bb9af7   #7aa2f7
client.focused_inactive #414868 #414868 #c0caf5 #414868   #414868
client.unfocused        #15161e #15161e #a9b1d6 #15161e   #15161e
client.urgent           #f7768e #f7768e #1a1b26 #f7768e   #f7768e
```

## Keybindings Philosophy

- Super key (Mod4) as primary modifier
- Vim-style directional keys (h,j,k,l) for navigation
- i3-style workspace management (number keys)
- Quick access to terminal (Super+Shift+Return), browser (Super+B),
  launcher (Super+D)
- Power menu accessible via keyboard (Super+P)

Full keybindings documented in README-UBUNTU.md.

## Package Translation Notes

### Packages Available in Ubuntu Repos

Most core packages available via apt:
- sway, waybar, wofi, mako, kitty, zathura
- neovim (via PPA for latest), tmux, zsh
- grim, slurp, wl-clipboard
- pipewire, wireplumber, pamixer

### Packages Requiring PPAs

- **Neovim**: Use `ppa:neovim-ppa/unstable` for 0.10+
- **Sway**: May need PPA for latest version

### Packages Requiring Snaps

- **Chromium**: Available as snap
- Some proprietary tools

### Packages to Build from Source

- **hyprpicker** replacement: Build wl-color-picker or use alternative
- **cliphist**: Build from source (Go application)
- **yazi**: Build from Rust source or use cargo

### AUR to Ubuntu Translation

See `packages-ubuntu.txt` for complete mapping.

## What Claude Code Should Help With

### Configuration Files

- Write and refine Sway config with thoughtful keybindings
- Create swaylock config for beautiful lock screen
- Set up waybar with useful, minimal modules
- Configure terminal emulator for aesthetics and functionality
- Maintain Tokyo Night theme consistency across all applications
- When adding Waybar modules, use MDI icons for consistency

### Scripts

- Write clean, well-commented bash scripts
- Ensure proper error handling and user feedback
- Make scripts modular and reusable
- Follow shell best practices (shellcheck compliance)
- Use appropriate exit codes
- Ensure no hardcoded paths (use `$HOME`, `$XDG_CONFIG_HOME`,
  `$SCRIPT_DIR`)

### Documentation

- Keep README-UBUNTU.md updated with user-facing setup instructions
- Add comments to complex configurations
- Document new features and keybindings
- Create troubleshooting notes when issues arise

### Testing and Validation

- Verify syntax of all config files before committing
- Test scripts for edge cases
- Ensure no hardcoded paths (use $HOME, $XDG_CONFIG_HOME, etc.)
- Validate package dependencies are in packages-ubuntu.txt
- Maintain XDG Base Directory compliance for all new configurations
- Test bootstrap-ubuntu.sh changes on fresh Ubuntu VM

## Known Context About Roger

- Chemical engineer with strong technical background
- Runs Linux with headless server (newton.local) for local LLMs
- Comfortable with terminal and scripting
- Values local control over cloud services
- Has experience with Python, C++, and system administration
- Interested in optimization and clean, efficient solutions
- Two machines: kelvin (desktop), watt (laptop)
- Uses Unison for real-time sync between machines and newton server
- **Migrating from Arch + Hyprland to Ubuntu + Sway for stability**

## Notes for Claude Code

- Roger wants to **build** this, not just use a pre-made config
- Explain decisions and trade-offs when suggesting configurations
- Provide options when multiple approaches exist
- Keep things simple and maintainable
- Focus on functionality over flashiness (Sway philosophy)
- Respect the "terminal-first" philosophy
- When suggesting packages, explain why they are needed and how to get
  them on Ubuntu
- **Markdown formatting rules** (apply to ALL .md files):
  - Always add blank lines after headings before content starts (MD022)
  - Keep all lines under 80 characters in length (MD013)
  - Break long lines naturally at sentence boundaries or logical points
  - When breaking list items, indent continuation lines with 2 spaces

## Icon System (Waybar and UI)

**Material Design Icons (MDI)** are used throughout for maximum
compatibility:

- Waybar modules use MDI codepoints (e.g., `󰻠` CPU, `󰍛` RAM, `󰋊` Disk)
- Font Awesome included as fallback
- If icons don't render: ensure `fonts-font-awesome` and appropriate MDI
  fonts are installed

When adding new Waybar modules or UI elements, prefer MDI icons over Font
Awesome for consistency.

## Current Project Status

### Branch Structure

- **main**: Arch Linux + Hyprland (stable, working)
- **ubuntu-sway**: Ubuntu + Sway (migration in progress)

### Migration Progress

#### Completed
- [x] Created ubuntu-sway branch
- [x] Created CLAUDE-UBUNTU.md

#### In Progress
- [ ] Translate packages.txt to packages-ubuntu.txt
- [ ] Create initial Sway configuration
- [ ] Adapt Waybar for Sway
- [ ] Create bootstrap-ubuntu.sh

#### Not Started
- [ ] Test on Ubuntu VM
- [ ] Deploy to watt (laptop)
- [ ] Deploy to kelvin (desktop)
- [ ] Cross-machine validation

### Key Validation Criteria

- ✅ Bootstrap runs without errors on fresh Ubuntu install (both machines)
- ✅ All hostname-specific configs apply correctly
- ✅ Unison auto-starts and syncs bidirectionally
- ✅ All GUI elements (Waybar, display manager) display correctly
- ✅ No hardcoded paths, fully portable
- ✅ Idempotent - safe to run multiple times

## Ubuntu-Specific Considerations

### systemd Services

Ubuntu uses systemd like Arch, but service names may differ:
- `ssh` vs `sshd`
- NetworkManager vs iwd (Ubuntu default)
- Check service availability before enabling

### Default Applications

Ubuntu comes with GNOME applications by default. We're replacing these
with:
- Files (Nautilus) → yazi (terminal)
- Text Editor (gedit) → Neovim
- Terminal (gnome-terminal) → Kitty

### Display Manager Options

**Option 1: GDM (GNOME Display Manager)** - Recommended for Ubuntu
- Default on Ubuntu
- Good Wayland support
- Heavy but reliable
- Auto-detects Sway session

**Option 2: LightDM**
- Lighter than GDM
- Good theme support
- May need manual Sway session configuration

**Option 3: SDDM** (current on Arch branch)
- Qt-based
- Tokyo Night theme available
- Less common on Ubuntu but supported

### Network Management

**Default: NetworkManager**
- GUI: nm-applet (system tray)
- TUI: nmtui
- CLI: nmcli

**Alternative: iwd** (used in Arch branch)
- Lighter weight
- TUI: impala
- Would need to disable NetworkManager and install iwd

Recommendation: Stick with NetworkManager for Ubuntu (default, well-tested)

## Success Criteria

- Can clone dotfiles repo on fresh Ubuntu install
- Run bootstrap-ubuntu.sh to deploy configs
- Have fully functional Sway desktop in < 1 hour
- All essential workflows accessible via terminal
- Beautiful, cohesive aesthetics throughout
- Zero GUI applications except browser and PDF viewer
- Rock-solid stability (main reason for Sway over Hyprland)
