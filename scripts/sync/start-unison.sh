#!/bin/bash
# Auto-start Unison sync in tmux session
# Called automatically on login via bashrc

if ! tmux has-session -t unison 2>/dev/null; then
  echo "Starting Unison tmux sync session..."
  tmux new -d -s unison "unison dev-sync -repeat watch"
fi
