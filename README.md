# Dotfiles - Hyprland Rice

Beautiful Tokyo Night themed Hyprland setup for Arch Linux with
terminal-first workflow and continuous sync to newton server.

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
- Install NvChad for Neovim
- Install nvm for Node.js

After bootstrap completes:

1. Restore SSH key from Dashlane: `~/dotfiles/scripts/ssh/restore-ssh-from-dashlane.sh`
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
- **Editor**: Neovim with NvChad
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

- Monitor scaling: 1.0x (no scaling)
- No battery indicator in waybar
- Config: `.config/hypr/hyprland-kelvin.conf`

### Laptop (watt)

- Monitor scaling: 1.5x (HiDPI)
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

This setup uses Unison for bidirectional real-time sync of the dev folder
with newton.local server.

### Initial Setup

```bash
# Restore SSH key from Dashlane
~/dotfiles/scripts/ssh/restore-ssh-from-dashlane.sh

# Test connection
ssh roger@newton.local
```

The SSH key is stored in Dashlane and retrieved on each new machine setup.
The restore script will prompt you to paste your private and public keys.

### Sync Workflow

On login, zsh automatically starts a tmux session named "unison" that runs
continuous file watching. Any changes in `~/dev` are immediately synced to
`newton.local`.

### Useful Commands

```bash
ssh-newton       # Connect to newton server
sync-now         # Manual one-time sync
sync-check       # Attach to sync tmux session
sync-stop        # Stop continuous sync
sync-log         # Watch sync log in real-time
```

### Sync Configuration

- Profile: `~/.unison/dev-sync.prf`
- Log: `~/.unison/dev-sync.log`
- Syncs: `~/dev` ↔ `roger@newton.local:/home/roger/dev`
- Mode: Continuous with `repeat = watch`

## Wallpaper

Place your wallpaper at `~/.local/share/wallpapers/wallpaper.jpg` or edit
`~/.config/hypr/hyprpaper.conf` to point to your preferred image.

Change wallpaper dynamically:

```bash
hyprctl hyprpaper wallpaper ",~/.local/share/wallpapers/new.jpg"
```

## Post-Install Steps

1. Restore SSH key from Dashlane: `~/dotfiles/scripts/ssh/restore-ssh-from-dashlane.sh`
2. Add wallpaper to `~/.local/share/wallpapers/wallpaper.jpg`
3. Open Neovim and run `:MasonInstallAll` for LSP support
4. Install Node.js: `nvm install --lts`

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
