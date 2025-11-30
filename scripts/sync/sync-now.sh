#!/bin/bash
# Manual one-time sync - run this to sync on demand

echo "Running one-time sync with newton..."

# Test if newton is reachable
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes roger@newton.local exit 2>/dev/null; then
    echo "ERROR: Cannot reach newton server"
    notify-send -u critical "Sync Failed" "Cannot reach newton.local"
    exit 1
fi

# Run one-time sync (no watch mode)
echo "Syncing dev folder..."
unison dev-sync

echo "Sync complete!"
notify-send "Sync Complete" "dev folder synced with newton"
