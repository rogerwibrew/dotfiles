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
- **Text Editor**: Neovim with NvChad
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

## Repository Structure

```
.
├── .config/
│   ├── hypr/               # Hyprland configuration
│   ├── zsh/
│   │   └── .zshrc          # Interactive shell config
│   ├── shell/
│   │   └── alias           # Shell aliases (modular)
│   ├── waybar/             # Status bar config
│   ├── nvim/               # Neovim configuration
│   ├── kitty/              # Terminal configuration
│   ├── wofi/               # Launcher styling
│   ├── mako/               # Notification daemon config
│   └── ...
├── scripts/                # Utility scripts
│   ├── power/              # Shutdown, reboot, suspend
│   ├── lock/               # Lock screen wrapper
│   ├── screenshot/         # Screenshot utilities
│   └── ...
├── wallpapers/             # Custom wallpapers
├── .zprofile               # Login shell, XDG environment variables
├── packages.txt            # List of all installed packages
├── bootstrap.sh            # Fresh install setup script
├── README.md               # User-facing documentation
└── CLAUDE.md               # This file
```

## Key Features to Implement

### Lock Screen and Screensaver

- Beautiful lock screen using swaylock-effects with blur and clock overlay
- Automatic locking via swayidle after inactivity
- DPMS screen blanking
- Inspired by Omarchy Linux aesthetics

### Dotfiles Management

- All configs in `.config` directory
- Git-tracked and version controlled
- Bootstrap script for fresh installations
- Either GNU stow or custom symlink script for deployment
- Packages list for reproducible installs

### Scripts Suite

- Power management (shutdown, reboot, suspend)
- Lock screen wrapper with custom effects
- Volume and brightness controls
- Screenshot utilities
- Waybar custom modules (if needed)
- Startup/autostart scripts

### Keybindings Philosophy

- Super key as primary modifier
- Vim-style directional keys (h,j,k,l) where appropriate
- Quick access to terminal, browser, launcher
- Power menu accessible via keyboard

## Technical Preferences

- **Package Management**: Use pacman and AUR (yay or paru)
- **Shell**: Bash for scripts (not zsh/fish for simplicity)
- **Configuration Format**: Native formats (no complex templating)
- **Dependencies**: Minimize external dependencies where possible
- **Documentation**: In-line comments in configs, README for setup process

## Development Approach

1. Start with minimal viable setup (Hyprland + terminal + basic keybindings)
2. Layer in features incrementally (status bar, launcher, lock screen)
3. Refine aesthetics (colors, fonts, spacing)
4. Create utility scripts as needs arise
5. Document as you build
6. Test on fresh Arch VM before committing

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

### Configuration Files

- Write and refine Hyprland config with thoughtful keybindings
- Create swaylock-effects config for beautiful lock screen
- Set up waybar with useful, minimal modules
- Configure terminal emulator for aesthetics and functionality

### Scripts

- Write clean, well-commented bash scripts
- Ensure proper error handling
- Make scripts modular and reusable
- Follow shell best practices

### Documentation

- Keep README updated with setup instructions
- Document keybindings in a reference file
- Add comments to complex configurations
- Create troubleshooting notes

### Testing and Validation

- Verify syntax of all config files
- Test scripts for edge cases
- Ensure no hardcoded paths (use $HOME, $XDG_CONFIG_HOME, etc.)
- Validate package dependencies
- Maintain XDG Base Directory compliance for all new configurations

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

## Current Status

Fully functional dotfiles system with:
- Complete Hyprland configuration with master layout
- Tokyo Night theme across all components
- Continuous sync to newton.local server via Unison
- Zsh shell with syntax highlighting, case-insensitive auto-completion,
  and vi mode
- XDG Base Directory compliance for clean home directory
- Modular shell configuration (.zprofile, .config/zsh/, .config/shell/)
- All essential utilities and scripts
- Hostname-specific configurations for kelvin (desktop) and watt (laptop)

## Success Criteria

- Can clone dotfiles repo on fresh Arch install
- Run bootstrap script to deploy configs
- Have fully functional Hyprland desktop in < 1 hour
- All essential workflows accessible via terminal
- Beautiful, cohesive aesthetics throughout
- Zero GUI applications except browser and PDF viewer
- Git history shows incremental, logical build process
