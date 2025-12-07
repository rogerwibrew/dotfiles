# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Project Overview

This repository contains a complete, reproducible dotfiles system for Arch
Linux with Hyprland. The core concept: clone this repo on a fresh Arch
install, run the bootstrap script, and have a fully functional window
manager with all configurations, scripts, and tools ready to use.

Goals:

- **Beautiful but simple**: Clean aesthetics without unnecessary complexity
- **Terminal-first**: If it can be done in the terminal, do it there
- **Minimal GUI**: Only browser and PDF viewer as GUI applications
- **Fully reproducible**: Everything needed is tracked in this repository

## Guiding Principles

- **Wayland-native**: Using Hyprland compositor and Wayland ecosystem
- **Version controlled**: All configs, scripts, and package lists in git
- **Bootstrap-ready**: Single script deployment on fresh Arch install
- **XDG compliant**: Following XDG Base Directory Specification for clean
  home directory

## Technology Stack

### Core Components

- **OS**: Arch Linux
- **Compositor**: Hyprland (Wayland)
- **Shell**: zsh with syntax highlighting, vi mode, and auto-completion
- **Text Editor**: Neovim with LazyVim
- **Terminal**: Kitty with ligature support
- **Browser**: Chromium
- **PDF Viewer**: Zathura
- **File Manager**: yazi (terminal-based)

### Wayland Ecosystem Tools

- **Status Bar**: Waybar with Tokyo Night theme
- **Launcher**: wofi
- **Lock Screen**: swaylock-effects
- **Idle Management**: swayidle (5 min idle → lock, 10 min → screen off)
- **Notifications**: mako
- **Screenshots**: grim + slurp
- **Clipboard**: wl-clipboard + cliphist
- **Wallpaper**: hyprpaper

### Development and Sync

- **Session Manager**: tmux with Tokyo Night theme
- **Sync Tool**: Unison with continuous file watching
- **Server**: newton.local (SSH with ed25519 keys, Avahi mDNS)
- **Synced Folders**: ~/dev and ~/data
- **Version Control**: git

## Core Architecture

### Configuration Deployment System

The dotfiles use **direct symlinking** (not GNU stow) via bootstrap.sh:

- Configs live in `~/dotfiles/.config/`
- Bootstrap creates symlinks: `~/.config/hypr` → `~/dotfiles/.config/hypr`
- Idempotent: Safe to run bootstrap.sh multiple times
- Hostname detection at runtime chooses kelvin vs watt configs
- See bootstrap.sh:1-18 for detailed execution order

After bootstrap, editing files in `~/dotfiles/.config/` directly updates
the active configuration (no re-bootstrap needed).

### Hostname-Specific Configuration Pattern

Two-layer config system for desktop vs laptop:

- **Base configs**: `.config/hypr/hyprland.conf` (reference/fallback)
- **Host-specific**: `.config/hypr/hyprland-kelvin.conf`,
  `hyprland-watt.conf`
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

## Common Development Commands

### Bootstrap and Testing

```bash
# Fresh install deployment (idempotent, safe to run multiple times)
cd ~/dotfiles
./bootstrap.sh

# Test bootstrap on VM (requires virt-manager)
./scripts/setup/create-test-vm.sh
./scripts/setup/setup-vm-testing.sh
```

### Dotfiles Management

```bash
# Push changes to git (via helper script)
~/dotfiles/scripts/git/dotfiles-push.sh
# Or use alias: dotfiles-push

# Pull and re-deploy configs
~/dotfiles/scripts/git/dotfiles-pull.sh
./bootstrap.sh

# After editing configs in ~/dotfiles/.config/, changes are live
# (symlinks auto-update, no re-bootstrap needed)
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
# Install new package and track it
yay -S package-name
echo "package-name" >> ~/dotfiles/packages.txt

# Update all packages
yay -Syu

# Reinstall from packages.txt (bootstrap does this automatically)
yay -S --needed $(grep -v '^#' packages.txt | grep -v '^$')
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

### Hyprland and Waybar

```bash
# Reload Hyprland config (or Super+Shift+E and re-login)
hyprctl reload

# Test specific keybinding
hyprctl dispatch exec kitty

# Restart waybar (if making changes)
pkill waybar && waybar &

# Check current Hyprland config being used
ls -l ~/.config/hypr/hyprland.conf
```

## Bootstrap Script Workflow

Understanding `bootstrap.sh` execution (see comments in file):

1. **System validation**: Check Arch Linux, user 'roger', set SCRIPT_DIR
2. **Install yay**: AUR helper (if not present)
3. **System update**: `yay -Syu`
4. **Package installation**: Parse `packages.txt`, install via yay
5. **External tools**: Dashlane CLI, Claude Code, nvm, Node.js LTS
6. **Directory creation**: `~/dev`, `~/data`, `~/downloads`,
   `.local/share/wallpapers`
7. **Symlink configs**: `.config/*`, `.zprofile`, `.zshenv` → dotfiles
   repo
8. **Install webapps**: Parse `webapps/webapps.txt`, install desktop
   entries and icons
9. **SDDM setup**: Tokyo Night theme with qt6-5compat for graphical
   effects
10. **mDNS configuration**: Auto-edit `/etc/nsswitch.conf` for .local
   resolution
11. **Enable services**: sshd, avahi-daemon, sddm
12. **Shell setup**: Change default shell to zsh via chsh

**Idempotency**: Safe to run multiple times; checks before
installing/symlinking.

**CRITICAL**: SCRIPT_DIR is set early (line 54) before any `cd` commands
to ensure correct paths throughout execution.

## Repository Structure

```
.
├── .config/
│   ├── hypr/               # Hyprland configuration
│   │   ├── hyprland.conf           # Base config (reference)
│   │   ├── hyprland-kelvin.conf    # Desktop-specific
│   │   ├── hyprland-watt.conf      # Laptop-specific
│   │   ├── hyprpaper.conf          # Wallpaper config
│   │   └── keybindings-apps.conf   # App launch keybindings
│   ├── zsh/
│   │   └── .zshrc          # Interactive shell config
│   ├── shell/
│   │   └── alias           # Shell aliases (modular)
│   ├── waybar/             # Status bar config
│   │   ├── config-kelvin   # Desktop waybar
│   │   ├── config-watt     # Laptop waybar
│   │   └── style.css       # Tokyo Night styling
│   ├── unison/             # Sync profiles
│   │   ├── dev-sync.prf    # ~/dev sync config
│   │   └── data-sync.prf   # ~/data sync config
│   ├── kitty/              # Terminal configuration
│   ├── wofi/               # App launcher styling
│   ├── mako/               # Notification daemon config
│   ├── swaylock/           # Lock screen config
│   ├── swayidle/           # Idle management config
│   └── tmux/               # Terminal multiplexer config
├── scripts/
│   ├── power/              # powermenu.sh (shutdown, reboot, suspend)
│   ├── ssh/                # SSH setup and restore scripts
│   ├── sync/               # Unison sync management scripts
│   ├── screenshot/         # Screenshot utilities (grim + slurp)
│   ├── git/                # Dotfiles git helpers
│   ├── setup/              # Installation scripts (Dashlane, VM testing)
│   ├── tui/                # TUI app launcher
│   ├── webapp/             # Web app installation
│   ├── volume-notify.sh    # Volume change notifications
│   └── brightness-notify.sh # Brightness notifications
├── sddm/                   # Tokyo Night SDDM theme
├── wallpapers/             # Custom wallpapers
├── webapps/                # Web application definitions
│   ├── icons/              # Webapp icons (svg format)
│   └── webapps.txt         # Webapp list (NAME|URL|ICON_FILE)
├── docs/                   # Additional documentation
├── .zprofile               # Login shell, XDG environment variables
├── .zshenv                 # Zsh environment (sources .zprofile)
├── packages.txt            # Package list (122 packages)
├── bootstrap.sh            # Installation script
├── README.md               # User-facing documentation
└── CLAUDE.md               # This file
```

## Technical Preferences

- **Package Management**: Use pacman and AUR (yay or paru)
- **Shell**: Bash for scripts (not zsh/fish for simplicity and portability)
- **Configuration Format**: Native formats (no complex templating)
- **Dependencies**: Minimize external dependencies where possible
- **Documentation**: In-line comments in configs, README for user-facing
  setup instructions
- **Paths**: Use environment variables ($HOME, $XDG_CONFIG_HOME, etc.)
  never hardcode paths
- **Testing**: Use VM testing scripts before deploying major changes

## Development Approach

1. Start with minimal viable setup (Hyprland + terminal + basic
   keybindings)
2. Layer in features incrementally (status bar, launcher, lock screen)
3. Refine aesthetics (colors, fonts, spacing)
4. Create utility scripts as needs arise
5. Document as you build
6. Test on fresh Arch VM before committing major changes

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

Reference: Waybar, Kitty, Hyprland, SDDM all use this palette.

## Keybindings Philosophy

- Super key as primary modifier
- Vim-style directional keys (h,j,k,l) for navigation where appropriate
- Master layout keybindings: J/K cycle windows, Return swaps to master,
  I/O add/remove master
- Quick access to terminal (Super+Shift+Return), browser (Super+B),
  launcher (Super+D)
- Power menu accessible via keyboard (Super+P)

Full keybindings documented in README.md.

## What Claude Code Should Help With

### Configuration Files

- Write and refine Hyprland config with thoughtful keybindings
- Create swaylock-effects config for beautiful lock screen
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
- Ensure no hardcoded paths (use `$HOME`, `$XDG_CONFIG_HOME`, `$SCRIPT_DIR`)

### Documentation

- Keep README.md updated with user-facing setup instructions
- Add comments to complex configurations
- Document new features and keybindings
- Create troubleshooting notes when issues arise

### Testing and Validation

- Verify syntax of all config files before committing
- Test scripts for edge cases
- Ensure no hardcoded paths (use $HOME, $XDG_CONFIG_HOME, etc.)
- Validate package dependencies are in packages.txt
- Maintain XDG Base Directory compliance for all new configurations
- Test bootstrap.sh changes on fresh Arch VM

## Known Context About Roger

- Chemical engineer with strong technical background
- Runs Linux with headless server (newton.local) for local LLMs
- Comfortable with terminal and scripting
- Values local control over cloud services
- Has experience with Python, C++, and system administration
- Interested in optimization and clean, efficient solutions
- Two machines: kelvin (desktop), watt (laptop)
- Uses Unison for real-time sync between machines and newton server

## Notes for Claude Code

- Roger wants to **build** this, not just use a pre-made config
- Explain decisions and trade-offs when suggesting configurations
- Provide options when multiple approaches exist
- Keep things simple and maintainable
- Focus on functionality over flashiness
- Respect the "terminal-first" philosophy
- When suggesting packages, explain why they are needed
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
- If icons don't render: ensure `ttf-font-awesome` and
  `ttf-material-design-icons-desktop-git` are installed

When adding new Waybar modules or UI elements, prefer MDI icons over Font
Awesome for consistency.

## Current System Status

### Working Features

- Complete Hyprland configuration with master layout
- Tokyo Night theme across all components
- LazyVim for Neovim
- Continuous sync to newton.local server via Unison (both dev and data
  folders)
- Avahi/mDNS for .local hostname resolution
- Zsh shell with syntax highlighting, case-insensitive auto-completion,
  and vi mode
- XDG Base Directory compliance for clean home directory
- Modular shell configuration (.zprofile, .config/zsh/, .config/shell/)
- All essential utilities and scripts
- Hostname-specific configurations for kelvin (desktop) and watt (laptop)
- 4K display support with proper scaling on watt (2.5x)
- GB keyboard layout on watt
- Automatic screen lock via swayidle (5 min idle, 10 min screen off)
- SDDM Tokyo Night login screen with qt6-5compat for effects
- Waybar with Material Design Icons (CPU, RAM, Disk, Network, Audio,
  Battery)

### Machines

- **kelvin** (desktop): 1.666667x scaling, no battery indicator
- **watt** (laptop): 2.5x scaling, 4K display, battery indicator, GB
  keyboard
- **newton** (server): Ubuntu 22.04 LTS, sync target

### Known Dependencies

Critical for bootstrap success:

- **qt6-5compat**: Required for SDDM Tokyo Night theme graphical effects
- **avahi + nss-mdns**: Required for .local hostname resolution
- **grep/sed**: Installed early as essential utilities (bootstrap.sh:59)
- **SSH key**: Must be restored before Unison can start syncing

## Success Criteria

- Can clone dotfiles repo on fresh Arch install
- Run bootstrap script to deploy configs
- Have fully functional Hyprland desktop in < 1 hour
- All essential workflows accessible via terminal
- Beautiful, cohesive aesthetics throughout
- Zero GUI applications except browser and PDF viewer
