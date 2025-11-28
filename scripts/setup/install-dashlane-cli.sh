#!/bin/bash
# Install Dashlane CLI from official GitHub releases
# Dashlane CLI is not available on AUR, so we install it manually

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# Check if already installed
if command -v dcli &>/dev/null; then
  CURRENT_VERSION=$(dcli --version 2>&1 | grep -oP '\d+\.\d+\.\d+' | head -1)
  info "Dashlane CLI already installed (version $CURRENT_VERSION)"
  read -p "Do you want to reinstall/update? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    success "Keeping existing installation"
    exit 0
  fi
fi

# Fetch latest release info from GitHub API
info "Fetching latest release information..."
RELEASE_INFO=$(curl -s https://api.github.com/repos/Dashlane/dashlane-cli/releases/latest)

# Extract version and download URL for Linux x64
VERSION=$(echo "$RELEASE_INFO" | grep -oP '"tag_name": "v\K[^"]+' | head -1)
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -oP '"browser_download_url": "\K[^"]+linux-x64\.zip' | head -1)

if [ -z "$VERSION" ] || [ -z "$DOWNLOAD_URL" ]; then
  error "Failed to fetch release information from GitHub"
fi

info "Latest version: $VERSION"
info "Download URL: $DOWNLOAD_URL"

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

info "Downloading Dashlane CLI v$VERSION..."
curl -L -o "$TEMP_DIR/dashlane-cli.zip" "$DOWNLOAD_URL"

# Extract the binary
info "Extracting..."
unzip -q "$TEMP_DIR/dashlane-cli.zip" -d "$TEMP_DIR"

# Install to /usr/local/bin (requires sudo)
info "Installing to /usr/local/bin (may require sudo)..."
sudo install -m 755 "$TEMP_DIR/dcli" /usr/local/bin/dcli

# Verify installation
if command -v dcli &>/dev/null; then
  INSTALLED_VERSION=$(dcli --version 2>&1 | grep -oP '\d+\.\d+\.\d+' | head -1)
  success "Dashlane CLI v$INSTALLED_VERSION installed successfully"
  info "Run 'dcli --help' to get started"
else
  error "Installation failed - dcli command not found"
fi
