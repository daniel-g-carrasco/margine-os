#!/usr/bin/env bash

set -euo pipefail

# Restart swaync in a way that preserves the Hyprland session environment.
#
# If a user service exists, prefer systemd user management.
# Otherwise fall back to the direct swaync launcher script.

if command -v systemctl >/dev/null 2>&1 && systemctl --user cat swaync.service >/dev/null 2>&1; then
  systemctl --user import-environment \
    WAYLAND_DISPLAY \
    DISPLAY \
    SWAYSOCK \
    HYPRLAND_INSTANCE_SIGNATURE \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_TYPE \
    XDG_RUNTIME_DIR >/dev/null 2>&1 || true
  systemctl --user stop swaync.service >/dev/null 2>&1 || true
  pkill -x swaync >/dev/null 2>&1 || true
  systemctl --user reset-failed swaync.service >/dev/null 2>&1 || true
  exec systemctl --user start swaync.service
fi

exec "$HOME/.config/swaync/launch.sh"
