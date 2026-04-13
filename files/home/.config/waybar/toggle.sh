#!/usr/bin/env bash

set -euo pipefail

# Toggle Waybar on the current session.
# When turning it back on, always go through `launch.sh` so config and logging
# stay consistent.

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar
else
  "$HOME/.config/waybar/launch.sh"
fi
