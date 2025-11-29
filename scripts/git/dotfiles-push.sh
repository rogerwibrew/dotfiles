#!/bin/bash
# Push dotfiles changes to GitHub
# Usage: dotfiles-push.sh [commit message]

DOTFILES_DIR="$HOME/dev/dotfiles"

# Change to dotfiles directory
cd "$DOTFILES_DIR" || {
    echo "Error: Could not change to dotfiles directory"
    exit 1
}

# Check if there are changes to commit
if [[ -z $(git status -s) ]]; then
    echo "No changes to commit in dotfiles"
    exit 0
fi

# Show what will be committed
echo "Changes to be committed:"
git status -s
echo ""

# Get commit message from argument or prompt user
if [[ -n "$1" ]]; then
    COMMIT_MSG="$*"
else
    echo -n "Enter commit message: "
    read -r COMMIT_MSG
    if [[ -z "$COMMIT_MSG" ]]; then
        echo "Error: Commit message cannot be empty"
        exit 1
    fi
fi

# Add all changes
git add .

# Commit with message
git commit -m "$COMMIT_MSG"

# Push to origin
echo ""
echo "Pushing to GitHub..."
git push

echo ""
echo "Dotfiles pushed successfully!"
