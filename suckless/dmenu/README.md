# dmenu Configuration

This directory contains the custom `config.h` for dmenu.

## Installation

The bootstrap script handles this automatically, but for manual installation:

```bash
# Clone dmenu source
cd ~/dotfiles/suckless
git clone https://git.suckless.org/dmenu

# Copy our config
cp config.h dmenu/config.h

# Build and install
cd dmenu
sudo make clean install
```

## Usage

```bash
# Run as application launcher
dmenu_run

# Pipe input to dmenu for selection
echo -e "option1\noption2\noption3" | dmenu

# With prompt
dmenu_run -p "Run:"
```

## Customization

Colors match the dwm configuration for visual consistency.
Font is JetBrains Mono at size 10.
