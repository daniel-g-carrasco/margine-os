#!/usr/bin/env bash

set -euo pipefail

if command -v systemctl >/dev/null 2>&1 && systemctl --user cat swaync.service >/dev/null 2>&1; then
  systemctl --user import-environment \
    WAYLAND_DISPLAY \
    DISPLAY \
    SWAYSOCK \
    HYPRLAND_INSTANCE_SIGNATURE \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_TYPE \
    XDG_RUNTIME_DIR >/dev/null 2>&1 || true
  systemctl --user reset-failed swaync.service >/dev/null 2>&1 || true
  if systemctl --user is-active --quiet swaync.service; then
    exec systemctl --user restart swaync.service
  fi
  exec systemctl --user start swaync.service
fi

exec "$HOME/.config/swaync/launch.sh"
