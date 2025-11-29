# SDDM Configuration

This directory contains the SDDM (Simple Desktop Display Manager)
configuration for the dotfiles system.

## Overview

SDDM is the display manager used for the login screen. The configuration
uses a minimal theme based on "where-is-my-sddm-theme" with Tokyo Night
colors for a clean, consistent aesthetic.

## Files

- `sddm.conf` - Main SDDM configuration file
- `themes/tokyo-night/` - Custom SDDM theme with Tokyo Night colors

## Theme Features

The Tokyo Night theme provides:

- **Minimal design**: Simple password input on dark background
- **Tokyo Night colors**: Matches the rest of the system theme
- **Clean feedback**: Blue border on input, red flash on wrong password
- **User selection**: Shows available users for easy login
- **Session selection**: Allows choosing between desktop environments

### Tokyo Night Color Palette

- Background: `#1a1b26` (Tokyo Night background)
- Text: `#c0caf5` (Tokyo Night foreground)
- Border: `#7aa2f7` (Tokyo Night blue)
- Cursor: `#7dcfff` (Tokyo Night cyan)
- Error: `#f7768e` (Tokyo Night red)

## Installation

The bootstrap script automatically:

1. Copies the theme to `/usr/share/sddm/themes/tokyo-night`
2. Copies the config to `/etc/sddm.conf`
3. Enables SDDM service

## Manual Installation

If you need to install manually:

```bash
# Copy theme
sudo cp -r sddm/themes/tokyo-night /usr/share/sddm/themes/

# Copy configuration
sudo cp sddm/sddm.conf /etc/sddm.conf

# Enable SDDM
sudo systemctl enable sddm.service
```

## Customization

To customize the theme, edit `themes/tokyo-night/theme.conf`.

Key settings:

- `passwordFontSize` - Size of password input (default: 96)
- `passwordInputWidth` - Width of input field (0.5 = half screen)
- `showUsersByDefault` - Show user selection (true/false)
- `background` - Path to background image (empty = solid color)
- `backgroundFill` - Solid background color

## Credits

Based on [where-is-my-sddm-theme](https://github.com/stepanzubkov/where-is-my-sddm-theme)
by stepanzubkov.

Inspired by Omarchy Linux's clean login screen aesthetic.
