if [[ "$(tty)" = "/dev/tty1" ]]; then
  pgrep leftwm || startx
fi
