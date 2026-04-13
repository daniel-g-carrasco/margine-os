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

Margine now ships a small custom icon set for its operational launchers under:

- `files/home/.local/share/icons/hicolor/scalable/apps`

Use a versioned custom icon when:

- the launcher is genuinely Margine-specific
- the action is safety-critical or operationally important
- the themed fallback is too generic to be immediately recognizable

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
- `Power Menu`

### Settings and operational controls

- `Power Tools`
- `Gaming Split-Lock Control`
- `Bluetooth Manager`
- `NetworkManager Applet`

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
- use a dedicated icon when it improves meaning materially
- avoid icon names that are too DE-specific unless the fallback story is acceptable
- keep Margine operational icons in one coherent visual family
- refresh the icon cache after changing versioned SVG assets

### Terminal policy

Use a terminal tool when:

- the action needs context before execution
- the action may require `sudo`
- the operator benefits from seeing the exact state before deciding

This is why:

- `Gaming Split-Lock Control` opens a terminal tool
- `Host Health Check` opens a terminal tool

while direct session actions remain direct launchers.

## Versioned Margine icon set

The current versioned icon set covers:

- `Update All`
- `Host Health Check`
- `Gaming Split-Lock Control`
- `Lock Screen`
- `Turn Off Displays`
- `Suspend`
- `Log Out`
- `Restart`
- `Power Off`
- `Power Menu`
- `Power Tools`

These icons are intentionally reserved for operational launchers where immediate
recognition matters more than generic DE consistency.

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
- `Power Menu` -> `~/.local/bin/margine-session-control menu`
  - baseline implementation uses `wlogout`; `hyprshutdown` is an optional fallback
  - if no backend is available, the launcher must fail safe and notify instead of logging out

### Other critical controls

- `Power Tools` -> `~/.local/bin/open-power-settings`
- `Gaming Split-Lock Control` -> `~/.local/bin/open-gaming-split-lock-menu`

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

### If the icons changed

Refresh the user icon cache after updating the versioned SVG assets:

```bash
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor
update-desktop-database ~/.local/share/applications 2>/dev/null || true
```

## Suggested future improvements

- extend the Margine icon set only when a launcher is operationally important
  enough to justify long-term maintenance
- decide whether `Power Tools` should stay terminal-based or move to a richer
  GTK control UI
- consider a dedicated `Maintenance` category if the launcher starts feeling too
  crowded
- add validation coverage for the presence of core launcher entries in the
  runtime health checks
