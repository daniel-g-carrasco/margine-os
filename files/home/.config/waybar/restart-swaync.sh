#!/usr/bin/env bash

set -euo pipefail

log_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
mkdir -p "$log_dir"

if ! command -v swaync >/dev/null 2>&1; then
  printf 'swaync is not installed\n' >&2
  exit 1
fi

pkill -x swaync >/dev/null 2>&1 || true

nohup swaync >"$log_dir/swaync.log" 2>&1 &
