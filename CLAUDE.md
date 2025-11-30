# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

This repository contains a complete, reproducible dotfiles system for Arch
Linux with Hyprland. The core concept: clone this repo on a fresh Arch
install, run the bootstrap script, and have a fully functional window manager
with all configurations, scripts, and tools ready to use.

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
- **Idle Management**: swayidle
- **Notifications**: mako
- **Screenshots**: grim + slurp
- **Clipboard**: wl-clipboard + cliphist
- **Wallpaper**: hyprpaper

### Development and Sync

- **Session Manager**: tmux with Tokyo Night theme
- **Sync Tool**: Unison with continuous file watching
- **Server**: newton.local (SSH with ed25519 keys)
- **Synced Folder**: ~/dev
- **Version Control**: git

## Common Commands

### Bootstrap and Setup

```bash
# Fresh install deployment
./bootstrap.sh

# Restore SSH keys from USB
~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh

# First-time Unison sync (after SSH keys restored)
~/dotfiles/scripts/sync/first-sync.sh
```

### Development Workflow

```bash
# SSH and sync
ssh-newton                  # Connect to newton.local server
sync-now                    # Manual one-time sync
tmux attach -t unison       # Monitor sync status
sync-log                    # Watch sync log in real-time

# Git operations in dotfiles repo
cd ~/dotfiles
git pull && ./bootstrap.sh  # Update dotfiles
```

### Testing Bootstrap Changes

When iterating on bootstrap script or configs:

```bash
# Bootstrap is idempotent - safe to run multiple times
./bootstrap.sh

# For fresh install validation, use VM testing scripts
~/dotfiles/scripts/setup/create-test-vm.sh
```

## Architecture Overview

### Hostname-Specific Configuration System

The system supports multiple machines (kelvin desktop, watt laptop) with
host-specific configs that are automatically selected during bootstrap:

**Hyprland**: Bootstrap symlinks `hyprland-$HOSTNAME.conf` →
`~/.config/hypr/hyprland.conf`

- `hyprland-kelvin.conf`: Desktop (1.666667x scaling, US layout)
- `hyprland-watt.conf`: Laptop (2.5x scaling for 4K, GB layout)

**Waybar**: Bootstrap symlinks `config-$HOSTNAME` → `~/.config/waybar/config`

- `config-kelvin`: Desktop (no battery indicator)
- `config-watt`: Laptop (includes battery module)

If hostname doesn't match kelvin/watt, bootstrap uses default configs and
warns.

### Shell Configuration Architecture (XDG Compliant)

Multi-file modular shell setup following XDG Base Directory spec:

1. **`.zshenv`** (always sourced first): Sets XDG environment variables,
   ensures clean home
2. **`.zprofile`** (login shells): Adds `~/.local/bin` to PATH, sets up nvm,
   cargo, go
3. **`.config/zsh/.zshrc`** (interactive shells): Prompt, completions, syntax
   highlighting, vi mode, auto-starts Unison sync in tmux
4. **`.config/shell/alias`** (sourced by .zshrc): Common aliases (ssh-newton,
   sync-*, etc.)

This keeps `~/` clean - only `.zshenv` and `.zprofile` in home, rest in
`.config/`.

### Unison Continuous Sync System

Bidirectional sync to newton.local server runs automatically on login:

**Architecture**:

1. `.config/zsh/.zshrc` checks on interactive shell start
2. If not in tmux session 'unison' → spawns detached tmux with dual panes
3. Pane 0: `unison dev-sync` (continuous watch mode)
4. Pane 1: `unison data-sync` (continuous watch mode)
5. Logs: `~/.unison/dev-sync.log` and `~/.unison/data-sync.log`

**Profiles**: `.config/unison/*.prf` (symlinked to `~/.unison/` by bootstrap)

- `dev-sync.prf`: Syncs `~/dev` with auto=true, prefer=newer, repeat=watch
- `data-sync.prf`: Syncs `~/data` with same settings

**First-time sync**: Must run `first-sync.sh` with `-ignorearchives` to
handle fresh install without existing Unison state. This prompts for conflict
resolution. After that, continuous sync runs automatically.

### Bootstrap Script Execution Flow

Critical ordering in `bootstrap.sh` (execution order matters):

1. **Set SCRIPT_DIR early** (before any `cd` commands) - fixes path issues
2. **Install essential utilities** (grep, sed, inetutils) - needed for parsing
3. **Install yay** - required for all subsequent package installs
4. **Install packages** from `packages.txt` (comments ignored)
5. **Install external tools** (Claude Code, nvm, LazyVim)
6. **Create directories** (`~/dev`, `~/data`, `~/downloads`)
7. **Symlink configs** (hostname-specific logic for hypr/waybar)
8. **Setup SDDM** theme with proper permissions (qt6-5compat required)
9. **Enable services** (audio, network, sshd, avahi)
10. **Configure mDNS** (edit `/etc/nsswitch.conf` for .local resolution)
11. **Change shell** to zsh

Bootstrap is idempotent - safe to run multiple times for testing iterations.

## Keybindings Philosophy

- Super key as primary modifier
- Vim-style directional keys (h,j,k,l) for navigation
- Master layout focus: J/K cycle windows, Return makes window master, I/O
  adjust master count
- Quick access: Super+Shift+Return (terminal), Super+D (launcher), Super+B
  (browser)
- Power menu: Super+P (uses scripts/power/powermenu.sh)

## Technical Preferences

- **Package Management**: Use pacman and AUR (yay or paru)
- **Shell**: Bash for scripts (not zsh/fish for simplicity and portability)
- **Configuration Format**: Native formats (no complex templating)
- **Dependencies**: Minimize external dependencies where possible
- **Testing**: Use VM testing scripts before deploying major changes

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

## What Claude Code Should Help With

### Configuration and Scripts

- Write well-commented bash scripts with proper error handling
- Ensure no hardcoded paths (use `$HOME`, `$XDG_CONFIG_HOME`, `$SCRIPT_DIR`)
- Maintain XDG Base Directory compliance for all new configurations
- Test scripts for edge cases and verify config syntax
- When adding Waybar modules, use MDI icons for consistency

## Known Context About Roger

- Chemical engineer with strong technical background
- Runs Linux (Omarchy) with headless server for local LLMs
- Comfortable with terminal and scripting
- Values local control over cloud services
- Has experience with Python, C++, and system administration
- Interested in optimization and clean, efficient solutions
- Previous experience with project completion tracking systems

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
- If icons don't render: ensure `ttf-font-awesome` and `ttf-material-design-icons-desktop-git` are installed

When adding new Waybar modules or UI elements, prefer MDI icons over Font
Awesome for consistency.
- /quit