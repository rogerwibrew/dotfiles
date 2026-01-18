#!/bin/sh
# ~/.xinitrc - X11 startup script
# This file is run by startx to launch the window manager

# Source shell profile for environment variables
[ -f ~/.zprofile ] && . ~/.zprofile

# Load Xresources
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

# Load hostname-specific Xresources (for HiDPI settings, etc.)
HOSTNAME=$(hostname)
[ -f ~/.Xresources-"$HOSTNAME" ] && xrdb -merge ~/.Xresources-"$HOSTNAME"

# Set keyboard repeat rate (300ms delay, 25 repeats/sec)
# Lower rate prevents accidental multiple window spawns with ZSA Moonlander
xset r rate 300 25

# Disable screen blanking (we handle this with slock manually)
xset s off
xset -dpms

# Set cursor theme
xsetroot -cursor_name left_ptr

# Set background color (simple solid color, no wallpaper for minimalism)
xsetroot -solid "#1a1b26"

# Optional: Set wallpaper with feh (uncomment if desired)
# [ -f ~/.local/share/wallpapers/wallpaper.jpg ] && feh --bg-fill ~/.local/share/wallpapers/wallpaper.jpg

# Start notification daemon
dunst &

# Start status bar (slstatus)
slstatus &

# Start network manager applet (optional, for WiFi management)
# nm-applet &

# Start bluetooth applet (optional)
# blueman-applet &

# Start dwm
# Loop to allow restarting dwm without logging out
while true; do
    dwm 2> ~/.dwm.log
    # If dwm exits normally (Mod+Shift+Q), this loop allows restart
    # To actually logout, use: pkill -KILL -u $USER
done
