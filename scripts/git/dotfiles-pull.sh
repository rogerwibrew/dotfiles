#!/bin/bash
# Pull dotfiles changes from GitHub
# Usage: dotfiles-pull.sh

DOTFILES_DIR="$HOME/dotfiles"

# Change to dotfiles directory
cd "$DOTFILES_DIR" || {
    echo "Error: Could not change to dotfiles directory"
    exit 1
}

# Check if there are uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo "Warning: You have uncommitted changes in dotfiles"
    git status -s
    echo ""
    echo -n "Stash changes and pull? (y/n): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        git stash
        echo "Changes stashed"
    else
        echo "Pull cancelled"
        exit 1
    fi
fi

# Pull from origin
echo "Pulling from GitHub..."
git pull

echo ""
echo "Dotfiles updated successfully!"
echo "Reload Hyprland config with: hyprctl reload"
