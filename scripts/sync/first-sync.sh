#!/bin/bash
# First-time Unison sync after fresh install
# Handles archive cleanup and initial synchronization
# Run this once after restoring SSH keys on a fresh install

set -e

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
info "First-time Unison synchronization"
echo ""

# Check if SSH to newton.local works
info "Testing SSH connection to newton.local..."
if ! ssh -o BatchMode=yes -o ConnectTimeout=5 roger@newton.local exit 2>/dev/null; then
  error "Cannot connect to newton.local - please ensure SSH keys are set up"
fi
success "SSH connection verified"

# Check if Unison profiles exist
if [ ! -f "$HOME/.unison/dev-sync.prf" ]; then
  error "Unison profile dev-sync.prf not found in ~/.unison/"
fi
if [ ! -f "$HOME/.unison/data-sync.prf" ]; then
  error "Unison profile data-sync.prf not found in ~/.unison/"
fi

# Sync dev folder
echo ""
echo "========================================"
info "Starting sync for ~/dev from newton.local"
echo "========================================"
echo ""
warning "Unison will show changes and ask for confirmation"
info "Recommended: Press 'f' to follow Unison's recommendations (prefer newer files)"
info "Or press '>' to prefer all files from newton (pull everything down)"
echo ""
sleep 3  # Give time to read instructions

if unison dev-sync -ignorearchives -batch=false; then
  success "dev-sync completed successfully"
else
  warning "dev-sync had issues - you may need to resolve conflicts manually"
fi

# Sync data folder
echo ""
echo "========================================"
info "dev-sync complete! Now syncing data folder..."
echo "========================================"
echo ""
sleep 2  # Brief pause to show message

if unison data-sync -ignorearchives -batch=false; then
  success "data-sync completed successfully"
else
  warning "data-sync had issues - you may need to resolve conflicts manually"
fi

# Clear any remaining temporary files
info "Cleaning up temporary archive files..."
rm -f ~/.unison/*.tmp 2>/dev/null || true
success "Cleanup complete"

echo ""
success "First-time sync complete!"
echo ""
info "From now on, Unison will sync automatically when you open a terminal"
info "To view sync status: tmux attach -t unison"
info "To manually sync now: ~/dotfiles/scripts/sync/start-unison.sh"
echo ""
