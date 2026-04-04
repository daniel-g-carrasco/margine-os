#!/usr/bin/env bash

set -euo pipefail

log_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p "$log_dir"

pkill -x waybar >/dev/null 2>&1 || true

nohup setsid env -u DISPLAY waybar \
  -c "$HOME/.config/waybar/config.jsonc" \
  -s "$HOME/.config/waybar/style.css" \
  >"$log_dir/waybar.log" 2>&1 < /dev/null &
