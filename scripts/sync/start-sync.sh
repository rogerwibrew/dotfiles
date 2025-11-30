#!/bin/bash
# Start Unison sync for dev and data folders
# Called automatically by tmux on startup

LOGFILE="$HOME/.unison/sync-startup.log"
mkdir -p "$HOME/.unison"

echo "[$(date)] Starting Unison sync..." >> "$LOGFILE"

# Test if newton is reachable
if ! ssh -o ConnectTimeout=5 -o BatchMode=yes roger@newton exit 2>/dev/null; then
    echo "[$(date)] ERROR: Cannot reach newton server" >> "$LOGFILE"
    notify-send -u critical "Sync Failed" "Cannot reach newton server"
    exit 1
fi

# Sync dev folder
echo "[$(date)] Syncing dev folder..." >> "$LOGFILE"
unison newton-dev >> "$LOGFILE" 2>&1 &
DEV_PID=$!

# Sync data folder
echo "[$(date)] Syncing data folder..." >> "$LOGFILE"
unison newton-data >> "$LOGFILE" 2>&1 &
DATA_PID=$!

# Wait for both to complete
wait $DEV_PID
DEV_EXIT=$?

wait $DATA_PID
DATA_EXIT=$?

if [ $DEV_EXIT -eq 0 ] && [ $DATA_EXIT -eq 0 ]; then
    echo "[$(date)] Sync completed successfully" >> "$LOGFILE"
    notify-send "Sync Complete" "dev and data folders synced with newton"
else
    echo "[$(date)] ERROR: Sync failed (dev:$DEV_EXIT data:$DATA_EXIT)" >> "$LOGFILE"
    notify-send -u critical "Sync Failed" "Check $LOGFILE for details"
fi
