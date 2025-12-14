# .zshenv - Always sourced first by zsh
# Sets XDG Base Directory variables and ZDOTDIR

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# NVM directory
export NVM_DIR="$XDG_DATA_HOME/nvm"

# Default programs (available to all shells)
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export BROWSER="chromium"

# Point zsh to XDG-compliant config directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
