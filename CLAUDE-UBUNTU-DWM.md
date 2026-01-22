# CLAUDE-UBUNTU-DWM.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository's **Ubuntu + dwm branch**.

**IMPORTANT**: This is the `ubuntu-dwm` branch. For other setups see:
- `main`: Arch Linux + Hyprland
- `debian-dwm`: Debian Stable + dwm
- `ubuntu-sway`: Ubuntu + Sway

## Project Overview

This repository contains a complete, reproducible dotfiles system for
Ubuntu LTS with dwm. The core concept: clone this repo on a fresh
Ubuntu install, run the bootstrap script, and have a fully functional
tiling window manager with all configurations, scripts, and tools.

### Philosophy: Stability Over Features

This setup prioritizes:
- **Rock-solid stability**: Ubuntu LTS, no rolling releases
- **Simplicity**: dwm on X11, no compositor, no visual effects
- **Terminal-first**: Everything possible done in terminal/TUI
- **Minimal maintenance**: Update when needed, not constantly
- **Hardware compatibility**: Ubuntu for better driver support (nvidia, etc.)

### What This Setup Is NOT

- No ricing or aesthetics beyond functional defaults
- No gaps, transparency, or animations
- No Wayland (X11 with dwm for maximum stability)
- No bleeding-edge packages

## Technology Stack

### Core Components

- **OS**: Ubuntu LTS (22.04+ / Jammy Jellyfish or newer)
- **WM**: dwm (compiled from source with custom config.h)
- **Display**: X11 (Xorg), no compositor
- **Shell**: zsh with syntax highlighting, vi mode
- **Text Editor**: Neovim with LazyVim
- **Terminal**: st (suckless terminal) or kitty
- **Browser**: Chromium (via Flatpak)
- **Launcher**: dmenu (compiled from source)
- **File Manager**: yazi (terminal-based)

### Suckless Tools (Compiled from Source)

All suckless tools are compiled from source in `~/dotfiles/suckless/`:
- **dwm**: Dynamic window manager
- **dmenu**: Application launcher
- **st**: Simple terminal (optional, kitty works too)
- **slstatus**: Status bar for dwm (optional)

### Rust CLI Tools (Modern Replacements)

All aliased to traditional command names in `.config/shell/alias`:

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
| tlrc | man/tldr | `alias tldr='tlrc'` |
| broot | tree | `alias tree='broot'` |
| hyperfine | time | (no alias, different use) |
| delta | diff | `alias diff='delta'` |

### Development and Sync

- **Session Manager**: tmux with minimal theme
- **Sync Tool**: Unison with continuous file watching
- **Server**: newton.local (SSH with ed25519 keys, Avahi mDNS)
- **Synced Folders**: ~/dev and ~/data
- **Version Control**: git with lazygit TUI

## Core Architecture

### Package Installation Strategy

**Ubuntu repos** for:
- Core system packages
- Libraries and dependencies
- Stable versions of common tools

**Flatpak** for:
- Chromium browser (sandboxed, auto-updates)
- Steam (gaming)
- Complex GUI applications

**Compile from source** for:
- dwm, dmenu, slstatus (suckless tools)
- Small CLI/TUI tools when Ubuntu version is too old

**Cargo (Rust)** for:
- Modern CLI replacements (eza, bat, fd, rg, etc.)
- Install to ~/.cargo/bin (already in PATH via .zprofile)

### Installation Locations

- `/usr/local/bin`: System-wide compiled binaries (dwm, dmenu)
- `~/.local/bin`: User-only binaries
- `~/.cargo/bin`: Rust tools installed via cargo

### Configuration Deployment System

The dotfiles use **direct symlinking** via bootstrap-ubuntu-dwm.sh:

- Configs live in `~/dotfiles/.config/`
- Bootstrap creates symlinks: `~/.config/nvim` → `~/dotfiles/.config/nvim`
- Suckless source code lives in `~/dotfiles/suckless/`
- Idempotent: Safe to run bootstrap multiple times

### Hostname-Specific Configuration

Three machines with different displays:

- **newton** (desktop): 32" 4K monitor, 144 DPI (1.5x scaling), wired network
- **watt** (laptop): HiDPI display, 192 DPI (2x scaling), GB keyboard
- **kelvin** (desktop): Standard scaling, 96 DPI (1x), US keyboard

dwm handles this via:
- `.Xresources` for DPI settings per host
- Separate Xresources files: `Xresources-kelvin`, `Xresources-watt`

### XDG Base Directory Compliance

Clean home directory via `.zprofile` environment variables:

- `XDG_CONFIG_HOME=~/.config`
- `XDG_DATA_HOME=~/.local/share`
- `XDG_CACHE_HOME=~/.cache`

## dwm Configuration

### Patching dwm

dwm is configured by editing `config.h` and recompiling. Our setup:

```
~/dotfiles/suckless/dwm/
├── config.h      # Our custom configuration
├── config.def.h  # Default config (reference)
├── dwm.c         # Source code
├── Makefile      # Build system
└── patches/      # Applied patches (documentation)
```

### Layouts (Only Two Needed)

1. **Master/Stack** (default `[]=`): One master window, rest stacked
2. **Monocle** (`[M]`): Fullscreen, one window visible

### Key Bindings

```c
// Modifier key
#define MODKEY Mod4Mask  // Super key

// Core bindings
{ MODKEY|ShiftMask, XK_Return, spawn, {.v = termcmd } },     // Terminal
{ MODKEY,           XK_d,      spawn, {.v = dmenucmd } },    // dmenu
{ MODKEY,           XK_w,      killclient, {0} },            // Close window
{ MODKEY,           XK_j,      focusstack, {.i = +1 } },     // Focus next
{ MODKEY,           XK_k,      focusstack, {.i = -1 } },     // Focus prev
{ MODKEY,           XK_Return, zoom, {0} },                  // Swap to master
{ MODKEY,           XK_h,      setmfact, {.f = -0.05} },     // Shrink master
{ MODKEY,           XK_l,      setmfact, {.f = +0.05} },     // Grow master
{ MODKEY,           XK_f,      setlayout, {.v = &layouts[1]} }, // Monocle
{ MODKEY,           XK_t,      setlayout, {.v = &layouts[0]} }, // Tiled
{ MODKEY|ShiftMask, XK_q,      quit, {0} },                  // Quit dwm

// Workspaces (tags in dwm terminology)
{ MODKEY,           XK_1,      view, {.ui = 1 << 0} },
{ MODKEY,           XK_2,      view, {.ui = 1 << 1} },
// ... etc

// Move to workspace
{ MODKEY|ShiftMask, XK_1,      tag, {.ui = 1 << 0} },
// ... etc
```

### No Visual Frills

```c
// config.h settings for minimal appearance
static const unsigned int borderpx  = 1;   // 1px border
static const unsigned int snap      = 32;
static const int showbar            = 1;
static const int topbar             = 1;
static const unsigned int gappx     = 0;   // NO gaps

// Simple colors (no transparency)
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";
```

## Common Development Commands

### Bootstrap and Deployment

```bash
# Fresh install deployment
cd ~/dotfiles
./bootstrap-ubuntu-dwm.sh

# Recompile dwm after config changes
cd ~/dotfiles/suckless/dwm
sudo make clean install

# Recompile dmenu after config changes
cd ~/dotfiles/suckless/dmenu
sudo make clean install
```

### Package Management

```bash
# Update system
sudo apt update && sudo apt upgrade

# Install package and track it
sudo apt install package-name
echo "package-name" >> ~/dotfiles/packages-debian.txt

# Flatpak management
flatpak update
flatpak install flathub org.chromium.Chromium
flatpak install flathub com.valvesoftware.Steam
```

### Rust CLI Tools

```bash
# Install all Rust tools
~/.local/bin/install-rust-tools.sh

# Update a specific tool
cargo install eza --force

# Update all Cargo tools
cargo install-update -a  # Requires cargo-update
```

### SSH and Sync

```bash
# Restore SSH keys
~/scripts/ssh/restore-ssh-from-usb.sh

# Manual sync
~/scripts/sync/sync-now.sh

# View sync status
tmux attach -t unison
```

### dwm Operations

```bash
# Reload dwm (recompile and restart)
cd ~/dotfiles/suckless/dwm && sudo make clean install
# Then: Mod+Shift+Q to quit, login again

# Or use the helper script
~/scripts/dwm/rebuild.sh
```

## Bootstrap Script Workflow

Understanding `bootstrap-ubuntu-dwm.sh` execution:

1. **System validation**: Check Ubuntu, user 'roger', set SCRIPT_DIR
2. **System update**: `apt update && apt upgrade`
3. **Install build dependencies**: Base build tools, Xorg libs
4. **Install apt packages**: Parse `packages-ubuntu-dwm.txt`
5. **Setup Flatpak**: Add Flathub, install Chromium and Steam
6. **Install Rust and cargo**: Via rustup
7. **Install Rust CLI tools**: Via cargo (eza, bat, fd, rg, etc.)
8. **Compile suckless tools**: dwm, dmenu, st
9. **Install external tools**: Claude Code, nvm, Node.js LTS
10. **Directory creation**: ~/dev, ~/data, ~/downloads
11. **Symlink configs**: .config/*, .zprofile, .zshenv, .xinitrc
12. **Configure X11**: .Xresources, .xinitrc
13. **Enable services**: SSH, Avahi
14. **Change shell**: Set zsh as default

## Repository Structure

```
.
├── .config/
│   ├── zsh/
│   │   └── .zshrc             # Interactive shell config
│   ├── shell/
│   │   └── alias              # Shell aliases (including Rust tools)
│   ├── kitty/                 # Terminal (if using kitty over st)
│   ├── yazi/                  # Terminal file manager
│   ├── unison/                # Sync profiles
│   ├── tmux/                  # Terminal multiplexer
│   └── nvim/                  # Neovim/LazyVim
├── suckless/                  # Suckless source code
│   ├── dwm/
│   │   ├── config.h           # dwm configuration
│   │   ├── config.def.h       # Default reference
│   │   └── Makefile
│   ├── dmenu/
│   │   ├── config.h           # dmenu configuration
│   │   └── Makefile
│   └── st/                    # Optional: suckless terminal
│       ├── config.h
│       └── Makefile
├── scripts/
│   ├── dwm/                   # dwm helper scripts
│   │   └── rebuild.sh         # Recompile and notify
│   ├── power/                 # Power menu
│   ├── ssh/                   # SSH management
│   ├── sync/                  # Unison sync
│   └── setup/                 # Installation helpers
├── .xinitrc                   # X11 startup script
├── .Xresources                # X11 resources (DPI, fonts)
├── .Xresources-kelvin         # Desktop-specific
├── .Xresources-watt           # Laptop-specific (HiDPI)
├── .zprofile                  # Login shell, XDG vars
├── .zshenv                    # Zsh environment
├── packages-debian.txt        # Debian package list
├── bootstrap-debian.sh        # Installation script
├── CLAUDE-DEBIAN.md           # This file
└── CLAUDE.md                  # Arch version (main branch)
```

## Technical Preferences

- **Package Management**: apt for system, Flatpak for complex GUI apps,
  cargo for Rust tools
- **Compilation**: Use /usr/local for system-wide, ~/.local for user-only
- **Shell**: Bash for scripts (POSIX-ish, portable)
- **Configuration**: Direct config.h for suckless, native formats elsewhere
- **Dependencies**: Minimize, prefer static linking where sensible
- **Updates**: Update when needed, not automatically. Stability over new
  features.

## dwm Patches

Minimal patches applied (documented in suckless/dwm/patches/):

- None by default. dwm works great out of the box with master/stack
  and monocle layouts.

If patches are added later, document them in the patches/ directory
with the .diff files and a README explaining each.

## X11 Configuration

### .xinitrc

```bash
#!/bin/sh

# Load Xresources
xrdb -merge ~/.Xresources

# Set keyboard repeat rate
xset r rate 300 50

# Start status bar (optional)
# slstatus &

# Start dwm
exec dwm
```

### .Xresources (Base)

```
! DPI setting (override in host-specific file)
Xft.dpi: 96

! Font rendering
Xft.antialias: true
Xft.hinting: true
Xft.hintstyle: hintslight
Xft.rgba: rgb
```

### .Xresources-watt (Laptop HiDPI)

```
! HiDPI for 4K laptop display
Xft.dpi: 192

! Cursor size for HiDPI
Xcursor.size: 48
```

## Gaming with Steam

Steam installed via Flatpak for sandboxing and easy updates:

```bash
flatpak install flathub com.valvesoftware.Steam
flatpak run com.valvesoftware.Steam
```

For Vulkan/gaming on AMD:
```bash
sudo apt install mesa-vulkan-drivers libvulkan1 vulkan-tools
```

## Known Context About Roger

- Chemical engineer with CS/AI background
- Runs newton as desktop (formerly headless server for local LLMs)
- Comfortable with terminal and scripting
- Values stability over bleeding edge (Ubuntu LTS + dwm)
- Previously used Omarchy Linux, Arch, Hyprland
- Building AI-powered portfolio projects
- Three machines: newton (desktop, 32" 4K), watt (laptop), kelvin (desktop)
- Uses Unison for real-time sync between machines
- Newton has Alienware hardware requiring Ubuntu for driver compatibility

## Notes for Claude Code

- Roger chose this setup specifically for **stability** - respect that
- dwm is configured via source code, not runtime config files
- Explain compilation steps when modifying dwm/dmenu
- Keep things minimal - no feature creep
- When suggesting packages, prefer Debian repos, then Flatpak, then cargo
- Don't suggest Wayland, compositors, or visual effects
- **Markdown formatting rules**:
  - Blank lines after headings
  - Lines under 80 characters
  - Break at sentence boundaries

## Rust CLI Tools Setup

All tools installed via cargo to ~/.cargo/bin (in PATH via .zprofile).

Installation order (some have dependencies):
1. Core tools first: eza, bat, fd-find, ripgrep
2. Then: dust, procs, bottom, zoxide
3. Optional: tlrc, broot, hyperfine, git-delta

Aliases in `.config/shell/alias`:
```bash
# Rust CLI tool aliases
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias cat='bat --paging=never'
alias less='bat'
alias find='fd'
alias grep='rg'
alias du='dust'
alias ps='procs'
alias top='btm'
alias htop='btm'
alias tree='eza --tree'
alias diff='delta'
alias tldr='tlrc'

# Keep originals accessible
alias ols='/bin/ls'
alias ocat='/bin/cat'
alias ofind='/usr/bin/find'
alias ogrep='/bin/grep'
```

## Success Criteria

- Fresh Ubuntu install + clone + bootstrap = working dwm in under 1 hour
- No visual frills, just functional tiling
- All terminal workflows accessible and fast
- Steam works for lightweight gaming
- Rock-solid stability - no random breakage
- Unison sync working with newton.local
