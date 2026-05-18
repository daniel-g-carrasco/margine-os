#!/usr/bin/env bash

set -euo pipefail

log_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p "$log_dir"

if ! command -v swaync >/dev/null 2>&1; then
  printf 'swaync is not installed\n' >&2
  exit 1
fi

export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=hyprland
export DESKTOP_SESSION=hyprland
export GDK_BACKEND=wayland

if command -v systemctl >/dev/null 2>&1 && systemctl --user cat swaync.service >/dev/null 2>&1; then
  systemctl --user import-environment \
    WAYLAND_DISPLAY \
    DISPLAY \
    SWAYSOCK \
    HYPRLAND_INSTANCE_SIGNATURE \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_TYPE \
    XDG_RUNTIME_DIR >/dev/null 2>&1 || true

  if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd \
      WAYLAND_DISPLAY \
      DISPLAY \
      SWAYSOCK \
      HYPRLAND_INSTANCE_SIGNATURE \
      XDG_CURRENT_DESKTOP \
      XDG_SESSION_TYPE \
      XDG_RUNTIME_DIR >/dev/null 2>&1 || true
  fi

  systemctl --user stop swaync.service >/dev/null 2>&1 || true
  pkill -x swaync >/dev/null 2>&1 || true
  systemctl --user reset-failed swaync.service >/dev/null 2>&1 || true

  exec systemctl --user start swaync.service
fi

pkill -x swaync >/dev/null 2>&1 || true

exec nohup setsid swaync \
  --replace \
  --skip-system-css \
  >"$log_dir/swaync.log" 2>&1 < /dev/null
