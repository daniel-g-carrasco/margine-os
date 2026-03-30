#!/usr/bin/env bash

set -euo pipefail

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar
else
  "$HOME/.config/waybar/launch.sh"
fi
