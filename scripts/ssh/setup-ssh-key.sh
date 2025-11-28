#!/bin/bash
# SSH key setup script for newton server
# Generates SSH key and copies it to the server

SERVER="newton.local"
SERVER_USER="roger"

echo "Setting up SSH key for $SERVER_USER@$SERVER"

# Check if SSH key already exists
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    echo "SSH key already exists at ~/.ssh/id_ed25519"
    read -p "Do you want to use the existing key? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Generating new SSH key..."
        ssh-keygen -t ed25519 -C "roger@$(hostname)" -f "$HOME/.ssh/id_ed25519"
    fi
else
    echo "Generating new SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "roger@$(hostname)" -f "$HOME/.ssh/id_ed25519"
fi

# Copy SSH key to server
echo "Copying SSH key to $SERVER..."
ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" "$SERVER_USER@$SERVER"

# Test connection
echo "Testing SSH connection..."
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$SERVER_USER@$SERVER" exit; then
    echo "✓ SSH key authentication successful!"
else
    echo "✗ SSH connection failed. Please check your configuration."
    exit 1
fi
