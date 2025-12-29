# Dotfiles - My Hyprland Non-Rice

I was using Omarchy linux. I loved it, but loved it too much. I spent far too much time messing with my setup. I decided to go back to basics and build a set up that is easily syncable across my devices. I also wanted to be able to set up my computer quickly after an Arch fresh install.

This is the result. My goals:

1. Attractive, but not easy to change. I did not want to be able to change themes with a few keystrokes, but it did need to look good enough by default. I chose tokyo night colours.
2. I want a terminal based set up. I only want GUI applications where there is no sense in using the terminal.
3. automatically sync files across all my machines including my server.

**Please note** this is highly customised to my build. If you happen across this, please do not simply clone and install. It references the names I use for my computers (Watt for my laptop, Kelvin for my desktop and Newton for my server.) If you do want to use it, then I suggest using the code as a base for your setup.

**Use of AI** This, by its nature, relies on scripts. I am useless at writing these so I leaned heavily on AI (specifically Claude Code) to write. I went through many, many iterations to get it working on my machines without issues. I do not vouch for the quality of the code, but I know it worked for me. I suspect that it is quite fragile and careless changes will break it easily.

**SSH** I have a step to add ssh keys as that is how I communicate between my computers and my server and to other services like github.

## Quick Start

On a fresh Arch Linux install:

```bash
git clone git@github.com:rogerwibrew/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The bootstrap script will:

- Install all packages via yay
- Set up zsh as default shell
- Symlink all configurations
- Install LazyVim for Neovim
- Install nvm for Node.js

After bootstrap completes:

1. Restore SSH key from USB: `~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh`
2. Reboot and select Hyprland from your display manager
3. Log in - Unison sync will start automatically in tmux

## System Requirements

- **User**: roger
- **Hostname**: kelvin (desktop) or watt (laptop)
- **OS**: Arch Linux

The bootstrap script will verify these requirements before proceeding.

## Features

- **Compositor**: Hyprland with master layout
- **Theme**: Tokyo Night color scheme throughout
- **Shell**: zsh with syntax highlighting, auto-completion, and vi mode
- **Terminal**: Kitty with ligature support
- **Editor**: Neovim with LazyVim
- **File Manager**: yazi (terminal-based)
- **Launcher**: wofi
- **Status Bar**: waybar
- **Lock Screen**: swaylock-effects
- **Notifications**: mako
- **Wallpaper**: hyprpaper
- **Sync**: Unison with continuous file watching to newton.local
- **Session Manager**: tmux with Tokyo Night theme
- **XDG Compliance**: Clean home directory following XDG Base Directory
  Specification

## Hostname-Specific Configurations

### Desktop (kelvin)

- Monitor scaling: 1.666667x
- No battery indicator in waybar
- Config: `.config/hypr/hyprland-kelvin.conf`

### Laptop (watt)

- Monitor scaling: 2.0x (HiDPI)
- Battery indicator in waybar
- Config: `.config/hypr/hyprland-watt.conf`

## Keybindings

### Applications

- `Super + Shift + Return` - Terminal (Kitty)
- `Super + D` - Application launcher (wofi)
- `Super + W` - Close window
- `Super + Shift + E` - Exit Hyprland
- `Super + L` - Lock screen

### Master Layout

**I used to use dwm and like their standard keybindings**

- `Super + J` - Cycle to next window
- `Super + K` - Cycle to previous window
- `Super + Return` - Make current window master
- `Super + I` - Add master window
- `Super + O` - Remove master window
- `Super + F` - Toggle fullscreen
- `Super + V` - Toggle floating

### Workspaces

- `Super + H` - Previous workspace
- `Super + L` - Next workspace
- `Super + 1-9` - Switch to workspace 1-9
- `Super + Shift + 1-9` - Move window to workspace 1-9

### Media Keys

- `XF86AudioRaiseVolume` - Volume up
- `XF86AudioLowerVolume` - Volume down
- `XF86AudioMute` - Toggle mute
- `XF86MonBrightnessUp` - Brightness up
- `XF86MonBrightnessDown` - Brightness down

### Screenshots

- `Print` - Screenshot selection to clipboard
- `Shift + Print` - Full screenshot to clipboard
- `Super + Print` - Screenshot selection to file

### Utilities

- `Super + P` - Power menu (shutdown, reboot, suspend, logout, lock)

## SSH and Sync to Newton Server

This setup uses Unison for bidirectional real-time sync of the dev and
data folders with newton.local server.

### Initial Setup

```bash
# Restore SSH key from USB
~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh

# Test connection
ssh roger@newton.local
```

The SSH key is backed up to USB and restored on each new machine setup.

### Sync Workflow

On login, zsh automatically starts a tmux session named "unison" that runs
continuous file watching. Any changes in `~/dev` or `~/data` are
immediately synced to `newton.local`.

### Useful Commands

```bash
ssh-newton       # Connect to newton server
sync-now         # Manual one-time sync
sync-check       # Attach to sync tmux session
sync-stop        # Stop continuous sync
sync-log         # Watch sync log in real-time
```

### Sync Configuration

- Profiles: `~/.unison/dev-sync.prf` and `~/.unison/data-sync.prf`
- Logs: `~/.unison/dev-sync.log` and `~/.unison/data-sync.log`
- Syncs:
  - `~/dev` ↔ `roger@newton.local:/home/roger/dev`
  - `~/data` ↔ `roger@newton.local:/home/roger/data`
- Mode: Continuous with `repeat = watch`

## Wallpaper

Place your wallpaper at `~/.local/share/wallpapers/wallpaper.jpg` or edit
`~/.config/hypr/hyprpaper.conf` to point to your preferred image.

Change wallpaper dynamically:

```bash
hyprctl hyprpaper wallpaper ",~/.local/share/wallpapers/new.jpg"
```

## Web Applications

The bootstrap automatically installs web applications defined in
`webapps/webapps.txt`. Each webapp runs in a standalone Chromium window
with its own desktop entry and icon.

### Pre-installed Webapps

- **Claude**: AI assistant at claude.ai
- **Gmail**: Email at mail.google.com
- **Keep**: Notes at keep.google.com
- **Chat GTP**: ChatGPT at chatgpt.com

Launch webapps from the app launcher (Super + D) or add keybindings in
Hyprland config.

### Adding New Webapps

To add a new webapp to the dotfiles:

1. Add entry to `webapps/webapps.txt`:

   ```
   App Name|https://example.com|icon-filename.svg
   ```

2. Place icon in `webapps/icons/` directory (optional, uses chromium
   icon if not provided)

3. Run bootstrap or install manually:
   ```bash
   ~/dotfiles/scripts/webapp/install-webapp.sh  # Interactive
   ~/dotfiles/scripts/setup/install-webapps.sh  # From webapps.txt
   ```

Icons can be downloaded from [dashboardicons.com](https://dashboardicons.com/).

### Removing Webapps

```bash
~/dotfiles/scripts/webapp/remove-webapp.sh
```

## Post-Install Steps

1. Restore SSH key from USB: `~/dotfiles/scripts/ssh/restore-ssh-from-usb.sh`
2. Run first-time Unison sync: `~/dotfiles/scripts/sync/first-sync.sh`
3. Reboot your system
4. Log in at SDDM (Tokyo Night theme)
5. Unison will auto-sync dev and data folders in background
6. Open Neovim - LazyVim will auto-install plugins (run `:LazyHealth` to verify)

## Home Directory Structure

The bootstrap script creates a clean home directory with three main
folders:

```
~/
├── dev/          # Development projects and source code
├── data/         # Personal data, documents, screenshots, etc.
└── downloads/    # Downloaded files
```

Screenshots are automatically saved to `~/data/screenshots/`.

### XDG Base Directory Compliance

This setup follows the XDG Base Directory Specification to keep your home
directory clean:

```
~/.config/        # Configuration files (XDG_CONFIG_HOME)
~/.local/share/   # Application data (XDG_DATA_HOME)
~/.cache/         # Temporary cache files (XDG_CACHE_HOME)
```

Most applications are configured to respect these directories, including:

- Zsh history → `~/.cache/zsh_history`
- Python history → `~/.cache/python_history`
- Node.js/nvm → `~/.local/share/nvm`
- Cargo/Rust → `~/.local/share/cargo`
- Go packages → `~/.local/share/go`

## Dotfiles Repository Structure

```
dotfiles/
├── .config/
│   ├── hypr/
│   │   ├── hyprland-kelvin.conf    # Desktop config
│   │   ├── hyprland-watt.conf      # Laptop config
│   │   ├── hyprland.conf            # Base config (backup)
│   │   └── hyprpaper.conf           # Wallpaper config
│   ├── zsh/
│   │   └── .zshrc                   # Interactive shell config
│   ├── shell/
│   │   └── alias                    # Shell aliases
│   ├── kitty/                       # Terminal config
│   ├── waybar/
│   │   ├── config-kelvin            # Desktop status bar
│   │   ├── config-watt              # Laptop status bar
│   │   └── style.css                # Waybar styling
│   ├── wofi/                        # App launcher
│   ├── mako/                        # Notifications
│   ├── yazi/                        # File manager
│   ├── swaylock/                    # Lock screen
│   ├── swayidle/                    # Idle management
│   ├── tmux/                        # Terminal multiplexer
│   └── unison/                      # Sync profiles
├── scripts/
│   ├── power/                       # Power menu
│   ├── ssh/                         # SSH setup scripts
│   ├── sync/                        # Sync management
│   ├── system/                      # System maintenance (safe-update.sh)
│   ├── screenshot/                  # Screenshot utilities
│   ├── volume-notify.sh             # Volume notifications
│   └── brightness-notify.sh         # Brightness notifications
├── wallpapers/                      # Custom wallpapers
├── .zprofile                        # Login shell, XDG variables
├── packages.txt                     # Package list
├── bootstrap.sh                     # Installation script
├── CLAUDE.md                        # AI assistant instructions
└── README.md                        # This file
```

## Updating Dotfiles

After making changes to configs in this repository:

```bash
cd ~/dotfiles
git pull
./bootstrap.sh
```

The script will backup existing configs before symlinking.

## System Maintenance

### Safe System Updates

Use the `safe-update` script to update your system with comprehensive
error checking and validation:

```bash
safe-update        # Full update with all checks
check-updates      # Dry run, see what would be updated
quick-update       # Skip slower validation steps
```

The safe-update script performs:

**Pre-update checks:**
- Disk space verification (minimum 2GB required)
- Pacman database integrity check
- Broken package detection
- Failed service detection
- Arch Linux news review
- Package list backup to `~/.cache/system-updates/`

**Update process:**
- Runs `yay -Syu` with error detection
- Captures all output to log file
- Stops immediately on any errors

**Post-update validation:**
- Checks for `.pacnew` configuration files
- Identifies orphaned packages (with removal option)
- Verifies kernel updates (recommends reboot if needed)
- Validates critical services (sddm, pipewire, avahi-daemon)

**Logs and backups:**
- Update logs: `~/.cache/system-updates/update-YYYYMMDD-HHMMSS.log`
- Package backups:
  `~/.cache/system-updates/packages-YYYYMMDD-HHMMSS.txt`

This prevents silent update failures and catches common issues before
they break your system.

## Color Scheme

Tokyo Night palette is used throughout all applications:

- Background: `#1a1b26`
- Foreground: `#c0caf5`
- Blue: `#7aa2f7`
- Purple: `#bb9af7`
- Cyan: `#7dcfff`
- Green: `#9ece6a`
- Yellow: `#e0af68`
- Red: `#f7768e`

## License

Personal dotfiles - use at your own discretion.
