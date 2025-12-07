#!/bin/bash
# Install web applications from webapps.txt during bootstrap
# Non-interactive version of webapp installation

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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
WEBAPPS_FILE="$DOTFILES_DIR/webapps/webapps.txt"
ICONS_DIR="$DOTFILES_DIR/webapps/icons"

# Check if webapps.txt exists
if [ ! -f "$WEBAPPS_FILE" ]; then
  warning "No webapps.txt found, skipping webapp installation"
  exit 0
fi

# Create target directories
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_TARGET_DIR="$HOME/.local/share/icons/webapps"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_TARGET_DIR"

info "Installing web applications from webapps.txt..."

# Read and process webapps.txt
INSTALLED_COUNT=0
while IFS='|' read -r APP_NAME APP_URL ICON_FILENAME; do
  # Skip comments and empty lines
  [[ "$APP_NAME" =~ ^#.*$ ]] && continue
  [[ -z "$APP_NAME" ]] && continue

  # Trim whitespace
  APP_NAME=$(echo "$APP_NAME" | xargs)
  APP_URL=$(echo "$APP_URL" | xargs)
  ICON_FILENAME=$(echo "$ICON_FILENAME" | xargs)

  # Validate required fields
  if [ -z "$APP_NAME" ] || [ -z "$APP_URL" ]; then
    warning "Skipping invalid entry: $APP_NAME|$APP_URL"
    continue
  fi

  # Sanitize app name for file names (lowercase, no spaces)
  APP_ID=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

  # Determine icon path
  ICON_PATH="chromium"  # Default icon
  if [ -n "$ICON_FILENAME" ] && [ -f "$ICONS_DIR/$ICON_FILENAME" ]; then
    # Copy icon to target directory
    cp "$ICONS_DIR/$ICON_FILENAME" "$ICON_TARGET_DIR/"
    ICON_PATH="$ICON_TARGET_DIR/$ICON_FILENAME"
  fi

  # Create desktop entry
  DESKTOP_FILE="$DESKTOP_DIR/webapp-${APP_ID}.desktop"

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

  info "Installed webapp: $APP_NAME"
  INSTALLED_COUNT=$((INSTALLED_COUNT + 1))

done < "$WEBAPPS_FILE"

if [ $INSTALLED_COUNT -gt 0 ]; then
  success "Installed $INSTALLED_COUNT web application(s)"
else
  warning "No web applications installed"
fi
