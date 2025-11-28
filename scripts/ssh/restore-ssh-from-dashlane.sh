#!/bin/bash
# Restore SSH key from Dashlane
# Run this before setup-ssh-key.sh on a fresh install

echo "Restoring SSH key from Dashlane..."

# Check if Dashlane CLI is installed
if ! command -v dcli &> /dev/null; then
    echo "ERROR: Dashlane CLI not installed"
    echo "Install with: ~/dotfiles/scripts/setup/install-dashlane-cli.sh"
    exit 1
fi

# Create .ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

echo ""
echo "Please log in to Dashlane to retrieve your SSH key"
echo ""

# Note: You'll need to manually retrieve and paste the key from Dashlane
# The exact command depends on how you've stored it in Dashlane
echo "Retrieve your SSH private key from Dashlane and paste it when prompted"
echo ""

# Interactive key retrieval
read -p "Press Enter when ready to paste your private key..."

echo "Paste your private key (press Ctrl+D when done):"
cat > ~/.ssh/id_ed25519

# Set correct permissions
chmod 600 ~/.ssh/id_ed25519

echo ""
echo "Now retrieve your public key from Dashlane and paste it..."
read -p "Press Enter when ready to paste your public key..."

echo "Paste your public key (press Ctrl+D when done):"
cat > ~/.ssh/id_ed25519.pub

# Set correct permissions
chmod 644 ~/.ssh/id_ed25519.pub

echo ""
echo "✓ SSH keys restored from Dashlane"
echo ""
echo "Testing SSH connection to newton.local..."
if ssh -o BatchMode=yes -o ConnectTimeout=5 roger@newton.local exit 2>/dev/null; then
    echo "✓ SSH connection successful!"
else
    echo "⚠ SSH connection failed - key may not be authorized on newton.local"
    echo "  Run: ssh-copy-id roger@newton.local (if password auth is enabled)"
fi
