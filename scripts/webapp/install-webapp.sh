#!/bin/bash
# Install a standalone web application using Chromium
# Creates a desktop entry and launches apps in their own window

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

echo ""
info "Web App Installer"
echo ""

# Prompt for app details
read -p "App name (e.g., YouTube): " APP_NAME
read -p "App URL (e.g., https://youtube.com): " APP_URL
read -p "Icon URL (optional, press Enter to skip): " ICON_URL

# Validate inputs
if [ -z "$APP_NAME" ] || [ -z "$APP_URL" ]; then
  error "App name and URL are required"
fi

# Sanitize app name for file names (lowercase, no spaces)
APP_ID=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Create directories
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/webapps"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

# Download icon if provided
ICON_PATH=""
if [ -n "$ICON_URL" ]; then
  info "Downloading icon..."
  ICON_EXT="${ICON_URL##*.}"
  ICON_PATH="$ICON_DIR/${APP_ID}.${ICON_EXT}"
  curl -L -o "$ICON_PATH" "$ICON_URL" 2>/dev/null || {
    warning "Failed to download icon, using default"
    ICON_PATH=""
  }
fi

# Use default icon if none provided or download failed
if [ -z "$ICON_PATH" ]; then
  ICON_PATH="chromium"
fi

# Create desktop entry
DESKTOP_FILE="$DESKTOP_DIR/webapp-${APP_ID}.desktop"

info "Creating desktop entry..."
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Comment=Web application for $APP_NAME
Exec=chromium --app=$APP_URL --class=webapp-${APP_ID}
Icon=$ICON_PATH
Terminal=false
Categories=Network;WebBrowser;
StartupWMClass=webapp-${APP_ID}
EOF

chmod +x "$DESKTOP_FILE"

success "Web app '$APP_NAME' installed successfully!"
echo ""
info "Usage:"
echo "  - Launch from app launcher (Super + D or wofi)"
echo "  - Desktop entry: $DESKTOP_FILE"
echo "  - To remove: rm $DESKTOP_FILE"
echo ""
info "To add a keybinding, edit ~/.config/hypr/hyprland.conf:"
echo "  bind = SUPER SHIFT, Y, exec, chromium --app=$APP_URL --class=webapp-${APP_ID}"
echo ""
