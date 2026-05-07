#!/usr/bin/env bash

set -euo pipefail

# Restart Waybar with the versioned Margine config and log startup output.
#
# Safe operator workflow:
# - edit `config.jsonc` or `style.css`
# - run this script
# - inspect `~/.cache/waybar.log` if the bar does not come back cleanly

log_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
log_file="${log_dir}/waybar.log"
mkdir -p "$log_dir"

refresh_hyprland_runtime_env() {
  local instances=""
  local instance=""
  local wl_socket=""

  command -v hyprctl >/dev/null 2>&1 || return 0

  instances="$(hyprctl instances -j 2>/dev/null || true)"
  [[ -n "$instances" ]] || return 0

  instance="$(
    printf '%s\n' "$instances" |
      sed -n 's/.*"instance"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
      head -n 1
  )"
  wl_socket="$(
    printf '%s\n' "$instances" |
      sed -n 's/.*"wl_socket"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
      head -n 1
  )"

  [[ -n "$instance" ]] && export HYPRLAND_INSTANCE_SIGNATURE="$instance"
  [[ -n "$wl_socket" ]] && export WAYLAND_DISPLAY="$wl_socket"
}

wait_for_hyprland_runtime_env() {
  local attempt=0
  local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

  export XDG_RUNTIME_DIR="$runtime_dir"
  export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-Hyprland}"
  export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
  export XDG_SESSION_DESKTOP="${XDG_SESSION_DESKTOP:-hyprland}"
  export DESKTOP_SESSION="${DESKTOP_SESSION:-hyprland}"
  export GDK_BACKEND="${GDK_BACKEND:-wayland}"

  for attempt in {1..40}; do
    refresh_hyprland_runtime_env

    if [[ -n "${WAYLAND_DISPLAY:-}" && -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}" ]]; then
      return 0
    fi

    sleep 0.1
  done

  return 1
}

{
  printf '[%(%F %T)T] Margine Waybar launcher invoked\n' -1
  printf 'XDG_RUNTIME_DIR=%s\n' "${XDG_RUNTIME_DIR:-}"
  printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-}"
  printf 'HYPRLAND_INSTANCE_SIGNATURE=%s\n' "${HYPRLAND_INSTANCE_SIGNATURE:-}"
} >"$log_file"

if ! wait_for_hyprland_runtime_env; then
  {
    printf '[%(%F %T)T] Hyprland runtime not ready; refusing to start Waybar\n' -1
    printf 'XDG_RUNTIME_DIR=%s\n' "${XDG_RUNTIME_DIR:-}"
    printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-}"
    printf 'HYPRLAND_INSTANCE_SIGNATURE=%s\n' "${HYPRLAND_INSTANCE_SIGNATURE:-}"
  } >>"$log_file"
  exit 1
fi

refresh_hyprland_runtime_env

# Replace any running instance so config changes apply immediately.
pkill -x waybar >/dev/null 2>&1 || true

# Unset DISPLAY to keep the session Wayland-first even if XWayland is around.
nohup setsid env -u DISPLAY waybar \
  -c "$HOME/.config/waybar/config.jsonc" \
  -s "$HOME/.config/waybar/style.css" \
  >>"$log_file" 2>&1 < /dev/null &
