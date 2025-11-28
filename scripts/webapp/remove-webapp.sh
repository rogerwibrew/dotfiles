#!/bin/bash
# Remove a standalone web application

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
info "Web App Remover"
echo ""

# Find installed web apps
DESKTOP_DIR="$HOME/.local/share/applications"
WEBAPPS=$(ls "$DESKTOP_DIR"/webapp-*.desktop 2>/dev/null | xargs -n1 basename 2>/dev/null || echo "")

if [ -z "$WEBAPPS" ]; then
  warning "No web apps found"
  exit 0
fi

echo "Installed web apps:"
echo "$WEBAPPS" | nl -w2 -s'. '
echo ""

# Prompt for selection
read -p "Enter number to remove (or 'q' to quit): " SELECTION

if [ "$SELECTION" = "q" ]; then
  info "Cancelled"
  exit 0
fi

# Get selected app
SELECTED_APP=$(echo "$WEBAPPS" | sed -n "${SELECTION}p")

if [ -z "$SELECTED_APP" ]; then
  error "Invalid selection"
fi

# Extract app name from desktop file
APP_NAME=$(grep "^Name=" "$DESKTOP_DIR/$SELECTED_APP" | cut -d'=' -f2)

# Confirm removal
echo ""
warning "Remove '$APP_NAME'?"
read -p "Continue? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  info "Cancelled"
  exit 0
fi

# Remove desktop entry
rm "$DESKTOP_DIR/$SELECTED_APP"

# Extract app ID to remove icon
APP_ID=$(echo "$SELECTED_APP" | sed 's/webapp-//' | sed 's/.desktop//')
ICON_DIR="$HOME/.local/share/icons/webapps"

if [ -f "$ICON_DIR/${APP_ID}."* ]; then
  rm "$ICON_DIR/${APP_ID}."* 2>/dev/null || true
fi

success "Web app '$APP_NAME' removed"
echo ""
