#!/bin/bash
# Auto-start Unison sync in tmux session
# Called automatically on login via bashrc
# Syncs both dev and data folders to newton.local

if ! tmux has-session -t unison 2>/dev/null; then
  echo "Starting Unison tmux sync session..."
  # Create tmux session with dev-sync in first pane
  tmux new -d -s unison "unison dev-sync -repeat watch"
  # Split window and run data-sync in second pane
  tmux split-window -t unison -v "unison data-sync -repeat watch"
  # Select layout for better visibility
  tmux select-layout -t unison even-vertical
fi
