#!/usr/bin/env bash

set -euo pipefail

# Restart Waybar with the versioned Margine config and log startup output.
#
# Safe operator workflow:
# - edit `config.jsonc` or `style.css`
# - run this script
# - inspect `~/.cache/waybar.log` if the bar does not come back cleanly

log_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p "$log_dir"

# Replace any running instance so config changes apply immediately.
pkill -x waybar >/dev/null 2>&1 || true

# Unset DISPLAY to keep the session Wayland-first even if XWayland is around.
nohup setsid env -u DISPLAY waybar \
  -c "$HOME/.config/waybar/config.jsonc" \
  -s "$HOME/.config/waybar/style.css" \
  >"$log_dir/waybar.log" 2>&1 < /dev/null &
