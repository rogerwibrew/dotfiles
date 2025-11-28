# TUI and WebApp Launcher Guide

Inspired by Omarchy Linux, this setup provides keyboard-driven access to
Terminal User Interface (TUI) applications and standalone web applications.

## TUI Applications

TUI apps launch in dedicated kitty terminal windows with proper window
classes for organization.

### Included TUI Apps

- **lazygit** - Git operations (Super + Shift + G)
- **lazydocker** - Docker management (Super + Shift + D)
- **btop** - System resource monitor (Super + Shift + B)
- **impala** - WiFi manager (Super + Shift + W)
- **yazi** - File manager (Super + Shift + F)
- **fastfetch** - System information

### Using TUI Apps

All TUI apps are accessible via keybindings (see above) or by running them
directly in your terminal:

```bash
lazygit      # Launch git TUI
lazydocker   # Launch docker TUI
btop         # Launch resource monitor
impala       # Launch WiFi manager
yazi         # Launch file manager
fastfetch    # Show system info
```

### Adding Custom TUI Keybindings

Edit `~/.config/hypr/keybindings-apps.conf`:

```conf
bind = SUPER SHIFT, <KEY>, exec, ~/.dotfiles/scripts/tui/launch-tui.sh <app-name>
```

## Web Applications

Web apps launch as standalone Chromium windows (frameless, isolated) perfect
for services like YouTube, Gmail, ChatGPT, etc.

### Installing a Web App

Use the installation script:

```bash
~/dotfiles/scripts/webapp/install-webapp.sh
```

You'll be prompted for:
- **App name**: Display name (e.g., "YouTube")
- **App URL**: Full URL (e.g., "https://youtube.com")
- **Icon URL**: Optional icon image URL

**Pro Tip**: For high-quality webapp icons, visit
[Dashboard Icons](https://dashboardicons.com/) - a curated collection of
beautiful, consistent icons for popular web services.

This creates:
- Desktop entry in `~/.local/share/applications/`
- Icon in `~/.local/share/icons/webapps/` (if provided)
- Launcher entry (accessible via Super + D)

### Example Web Apps to Install

```bash
# YouTube
App name: YouTube
App URL: https://youtube.com
Icon URL: https://www.youtube.com/s/desktop/favicon_144x144.png

# Gmail
App name: Gmail
App URL: https://mail.google.com
Icon URL: https://ssl.gstatic.com/ui/v1/icons/mail/rfr/gmail.ico

# ChatGPT
App name: ChatGPT
App URL: https://chat.openai.com
Icon URL: https://cdn.oaistatic.com/assets/apple-touch-icon.png

# GitHub
App name: GitHub
App URL: https://github.com
Icon URL: https://github.githubassets.com/favicons/favicon.png
```

### Adding Keybindings to Web Apps

After installing a web app, add a keybinding in
`~/.config/hypr/keybindings-apps.conf`:

```conf
# YouTube webapp
bind = SUPER SHIFT, Y, exec, chromium --app=https://youtube.com --class=webapp-youtube
```

Then reload Hyprland config (Super + Shift + R or restart Hyprland).

### Removing a Web App

Use the removal script:

```bash
~/dotfiles/scripts/webapp/remove-webapp.sh
```

Select the app to remove from the list.

## How It Works

### TUI Apps

The `launch-tui.sh` script:
1. Checks if the TUI app is installed
2. Launches it in a new kitty window
3. Sets window class for proper organization
4. Sets window title to app name

### Web Apps

Web apps use Chromium's `--app` flag which:
- Removes browser UI (address bar, tabs, etc.)
- Creates a standalone window
- Isolates the app with a unique window class
- Makes it feel like a native application

The `--class` parameter ensures proper window management in Hyprland.

## Advantages

### Terminal-First Philosophy

- All tools accessible via keyboard
- No mouse required
- Fast, efficient workflow
- Consistent interface across tools

### Standalone Web Apps

- Less memory than full browser windows
- Clean, distraction-free interface
- Organized in task bar/workspace
- Persistent sessions

### Keyboard-Driven

- Quick access via shortcuts
- No context switching
- Muscle memory development
- Productive workflow

## Customization

All keybindings are in `~/.config/hypr/keybindings-apps.conf`. Edit this
file to:

- Add new TUI app shortcuts
- Add web app shortcuts
- Change existing keybindings
- Organize by category

After editing, reload Hyprland config to apply changes.

## Troubleshooting

### TUI app won't launch

Check if installed:
```bash
which <app-name>
```

Install if missing:
```bash
yay -S <app-name>
```

### Web app icon not showing

Icons may take time to cache. Try:
1. Log out and back in
2. Or provide a direct image URL when installing

### Keybinding conflicts

If a keybinding doesn't work, check for conflicts in main Hyprland config.
Each keybinding should be unique.

## Reference

**TUI Launch Script**: `~/dotfiles/scripts/tui/launch-tui.sh`
**Install WebApp**: `~/dotfiles/scripts/webapp/install-webapp.sh`
**Remove WebApp**: `~/dotfiles/scripts/webapp/remove-webapp.sh`
**Keybindings Config**: `~/.config/hypr/keybindings-apps.conf`
