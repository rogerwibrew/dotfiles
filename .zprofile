#!/bin/zsh
# .zprofile - Login shell configuration
# Sets up XDG Base Directory Specification for clean home directory

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Zsh configuration directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Application-specific XDG compliance
export HISTFILE="$XDG_CACHE_HOME/zsh_history"

# Python
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHON_HISTORY="$XDG_CACHE_HOME/python_history"

# Rust/Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Go
export GOPATH="$XDG_DATA_HOME/go"

# Node.js/npm
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NODE_REPL_HISTORY="$XDG_CACHE_HOME/node_repl_history"

# NVM
export NVM_DIR="$XDG_DATA_HOME/nvm"

# GTK
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# GnuPG
export GNUPGHOME="$XDG_DATA_HOME/gnupg"

# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"

# GNU Parallel
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"

# Default programs
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export BROWSER="chromium"

# Add local binaries to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add cargo binaries to PATH if cargo is installed
[[ -d "$CARGO_HOME/bin" ]] && export PATH="$CARGO_HOME/bin:$PATH"

# Load zshrc from ZDOTDIR
[[ -f "$ZDOTDIR/.zshrc" ]] && source "$ZDOTDIR/.zshrc"
