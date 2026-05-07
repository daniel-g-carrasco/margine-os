# 2026-05-07 - Walker/Elephant graphical-session race

## Context

After a host reboot, Walker opened from `Super+Space`, listed applications, and
logged desktop activation events, but selected applications did not open.

The failing boot showed `elephant.service` starting before the Hyprland runtime
environment had been imported into the systemd user manager. Elephant attempted
to initialize against `/run/user/1000/wayland-0`, while the active Hyprland
socket was `wayland-1`.

## Root Cause

`walker.service` was enabled under `default.target`. That target can start as
soon as the user manager starts, before Hyprland has established the real
`WAYLAND_DISPLAY` and before `margine-import-session-environment` has imported
the session variables into systemd and DBus activation.

This creates a dangerous partial-failure mode:

- Walker can still display results.
- Elephant can still log `desktopapplications activated=...`.
- Launched desktop applications inherit the wrong display/session environment
  and fail to appear.

## Fix

- `walker.service` is no longer enabled by runtime provisioning under
  `default.target`.
- Legacy `default.target.wants/walker.service` links are removed during runtime
  provisioning.
- Hyprland remains responsible for the warm launcher path through:
  `margine-import-session-environment` -> `margine-launcher-service`.
- `margine-launcher-service` starts Walker after environment import and then
  immediately runs the Walker healthcheck in repair mode.
- The `Super+Space` path runs the same healthcheck before reusing an existing
  Walker socket.
- The healthcheck restarts Walker and Elephant together when either process has
  a stale `WAYLAND_DISPLAY`.

## Required Invariant

Walker and Elephant must not be eagerly started from the systemd user
`default.target`. They may be warmed only after the graphical session environment
has been imported.

## Host Verification

Expected host state:

```sh
find ~/.config/systemd/user -maxdepth 3 -type l -name walker.service -print
```

prints no `default.target.wants/walker.service` entry.

For active processes:

```sh
for name in elephant walker; do
  for pid in $(pgrep -xu "$(id -u)" -x "$name" || true); do
    tr '\0' '\n' <"/proc/$pid/environ" | grep -E '^(WAYLAND_DISPLAY|DISPLAY|XDG_CURRENT_DESKTOP|DBUS_SESSION_BUS_ADDRESS)='
  done
done
```

`WAYLAND_DISPLAY` must match the active Hyprland socket from:

```sh
hyprctl instances -j
```
