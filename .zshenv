# .zshenv - Always sourced first by zsh
# Sets ZDOTDIR to tell zsh where to find .zshrc

# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Point zsh to XDG-compliant config directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
