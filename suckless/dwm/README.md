# dwm Configuration

This directory contains the custom `config.h` for dwm.

## Installation

The bootstrap script handles this automatically, but for manual installation:

```bash
# Clone dwm source
cd ~/dotfiles/suckless
git clone https://git.suckless.org/dwm

# Copy our config
cp config.h dwm/config.h

# Build and install
cd dwm
sudo make clean install
```

## Rebuilding After Config Changes

```bash
cd ~/dotfiles/suckless/dwm
sudo make clean install
# Then logout/login or Mod+Shift+Q and restart X
```

## Key Bindings

| Key | Action |
|-----|--------|
| Mod+Shift+Return | Open terminal (kitty) |
| Mod+d | dmenu launcher |
| Mod+b | Open browser (Chromium) |
| Mod+w | Close window |
| Mod+j/k | Focus next/previous window |
| Mod+Return | Swap window to master |
| Mod+h/l | Shrink/grow master area |
| Mod+i/o | Add/remove from master |
| Mod+t | Tiled layout (master/stack) |
| Mod+f | Monocle layout (fullscreen) |
| Mod+1-9 | Switch to workspace |
| Mod+Shift+1-9 | Move window to workspace |
| Mod+Shift+q | Quit dwm |
| Mod+Ctrl+l | Lock screen (slock) |
| Print | Screenshot (selection) |
| Shift+Print | Screenshot (full) |

## Patches

No patches applied. dwm works great out of the box with master/stack
and monocle layouts.

If patches are needed later, add .diff files to `patches/` and document
them here.
