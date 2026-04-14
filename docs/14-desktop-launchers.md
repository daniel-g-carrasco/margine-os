# Desktop Launchers

## Goal

`Margine` treats desktop launchers as a versioned subsystem, not as random
`.desktop` files added ad hoc over time.

This document defines:

- where launchers live
- which layer owns which part
- which launchers are considered baseline
- how to add or modify them safely

## Ownership model

Desktop launchers are split into three pieces on purpose.

### 1. Desktop entry files

The visible launcher entries live under:

- `files/home/.local/share/applications/*.desktop`

These are installed through:

- `scripts/provision-user-app-config`

### 2. Action backends and terminal wrappers

The commands launched by those entries live under:

- `files/home/.local/bin/*`

Desktop/session-oriented helpers are currently installed through:

- `scripts/provision-hyprland-desktop`

This includes:

- session actions such as lock, logout, reboot, power off, and display off
- terminal control tools such as host-health and split-lock control
- wrappers that open those tools in a themed terminal window

### 3. Icons

Launchers should prefer stable icon-theme names when possible.

## Baseline launcher groups

The current baseline is grouped intentionally.

### Maintenance and diagnostics

- `Update All`
- `Host Health Check`

### Security and session control

- `Lock Screen`
- `Turn Off Displays`
- `Suspend`
- `Log Out`
- `Restart`
- `Power Off`
- `Session Actions`

### Settings and operational controls

- `Power Tools`
- `Gaming Split-Lock Control`
- `Advanced Network Configuration`
- `Plasma Network Management (Test)`
- `Bluetooth Manager`

## Launcher design rules

### Names

- keep names in English
- use action-first names when the entry performs a direct action
- use tool-oriented names when the entry opens a terminal control UI

### Safety

- destructive actions must be explicit
- kernel/security-affecting toggles must not be one-click actions from Waybar
- terminal tools are preferred when the operator needs context before acting

### Icons

- prefer readable themed icons over novelty
- avoid icon names that are too DE-specific unless the fallback story is acceptable
- prefer stable icon-theme names from the active icon set first
- introduce versioned custom icons only when a themed icon is genuinely missing

### Terminal policy

Use a terminal tool when:

- the action needs context before execution
- the action may require `sudo`
- the operator benefits from seeing the exact state before deciding

This is why:

- `Gaming Split-Lock Control` opens a terminal tool
- `Host Health Check` opens a terminal tool
- `Session Actions` opens a terminal tool

while direct session actions remain direct launchers.

## Current core launchers

### Maintenance

- `Update All` -> `~/.local/bin/update-all-launcher`
- `Host Health Check` -> `~/.local/bin/open-host-health-menu`

### Session

- `Lock Screen` -> `~/.local/bin/margine-session-control lock`
- `Turn Off Displays` -> `~/.local/bin/margine-session-control display-off`
- `Suspend` -> `~/.local/bin/margine-session-control suspend`
- `Log Out` -> `~/.local/bin/margine-session-control logout`
- `Restart` -> `~/.local/bin/margine-session-control reboot`
- `Power Off` -> `~/.local/bin/margine-session-control poweroff`

### Other critical controls

- `Session Actions` -> `~/.local/bin/open-session-actions-menu`
- `Power Tools` -> `~/.local/bin/open-power-settings`
- `Gaming Split-Lock Control` -> `~/.local/bin/open-gaming-split-lock-menu`
- `Advanced Network Configuration` -> `gtk-dark-exec nm-connection-editor`
- `Plasma Network Management (Test)` -> `~/.local/bin/open-plasma-network-management`

## How to modify launchers safely

When changing launcher behavior, identify which layer changed.

### If the `.desktop` files changed

Run:

```bash
sudo /root/margine-os/scripts/provision-user-app-config --username daniel
update-desktop-database ~/.local/share/applications 2>/dev/null || true
```

### If the helper scripts changed

Run:

```bash
sudo /root/margine-os/scripts/provision-hyprland-desktop --username daniel
```

### If both changed

Run both, then refresh the session components that depend on them:

```bash
sudo /root/margine-os/scripts/provision-user-app-config --username daniel
sudo /root/margine-os/scripts/provision-hyprland-desktop --username daniel
update-desktop-database ~/.local/share/applications 2>/dev/null || true
hyprctl reload
```

## Suggested future improvements

- add custom icons only for launchers where Papirus or the active icon theme
  has no acceptable match
- decide whether `Power Tools` should stay terminal-based or move to a richer
  GTK control UI
- consider a dedicated `Maintenance` category if the launcher starts feeling too
  crowded
- add validation coverage for the presence of core launcher entries in the
  runtime health checks
