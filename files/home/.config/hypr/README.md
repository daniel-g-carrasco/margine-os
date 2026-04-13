# Margine Hyprland Guide

This directory is intentionally split into small files.

The goal is:

- keep `hyprland.conf` short
- keep related settings close together
- make common edits predictable
- avoid searching through one giant file for every change

## File map

- `hyprland.conf`
  Entry point only. It defines include order through `source = ...`.
- `monitors.conf`
  Monitor topology, scale, and placement.
- `hypridle.conf`
  Idle policy: dim, lock, DPMS-off, suspend.
- `conf.d/10-variables.conf`
  Modifier aliases and launcher variables like `$terminal` and `$browser`.
- `conf.d/20-autostart.conf`
  `exec-once` session startup programs and daemons.
- `conf.d/30-environment.conf`
  Environment variables and XWayland behavior.
- `conf.d/40-look-and-feel.conf`
  Gaps, borders, decoration, blur, animation, layout defaults.
- `conf.d/50-input.conf`
  Keyboard, touchpad, gestures, and device overrides.
- `conf.d/60-binds-apps.conf`
  App launchers and operator helpers.
- `conf.d/61-binds-session.conf`
  Locking, logout, reboot, and session-level actions.
- `conf.d/62-binds-windows.conf`
  Focus, floating, fullscreen, grouping, resize, mouse actions.
- `conf.d/63-binds-workspaces.conf`
  Workspace switching, moving windows between workspaces, scratchpad.
- `conf.d/64-binds-media.conf`
  Screenshot, recording, audio, brightness, and media keys.
- `conf.d/70-rules.conf`
  `layerrule`, `windowrule`, and placement policy.

## Common edit recipes

### Add or change an app shortcut

Edit:

- `conf.d/10-variables.conf` if you need a new `$variable`
- `conf.d/60-binds-apps.conf` for the actual bind

Example:

```ini
$editor = kitty -e nvim
bind = $mainMod, E, exec, $editor
```

For binds that should be self-documenting in `hyprctl binds`, prefer:

```ini
bindd = $mainMod, E, Open editor, exec, $editor
```

### Add a new startup daemon

Edit:

- `conf.d/20-autostart.conf`

Use `exec-once` when the process should start exactly once per login.

### Change gaps, borders, blur, or animation speed

Edit:

- `conf.d/40-look-and-feel.conf`

### Change keyboard or touchpad behavior

Edit:

- `conf.d/50-input.conf`

For hardware-specific overrides, prefer a `device { ... }` block instead of
changing the global `input` defaults.

### Add a new workspace shortcut

Edit:

- `conf.d/63-binds-workspaces.conf`

### Change monitor topology or scale

Edit:

- `monitors.conf`

Useful live check:

```bash
hyprctl monitors all
```

Keep the explicit monitor rules above the fallback rule.

### Change idle, lock, DPMS, or suspend timing

Edit:

- `hypridle.conf`

Keep the stages ordered from least destructive to most destructive:
dim, lock, displays off, suspend.

### Add a new screenshot, volume, or media shortcut

Edit:

- `conf.d/64-binds-media.conf`

### Add a window rule

Edit:

- `conf.d/70-rules.conf`

Keep one logical rule block per behavior. Name it if the rule is not trivial.

## Safe workflow

After editing Hyprland config:

```bash
hyprctl reload
hyprctl configerrors
```

If `configerrors` prints anything, fix that before considering the change done.

## Official wiki map

- General keywords and file sourcing:
  https://wiki.hypr.land/Configuring/Keywords/
- Variables and categories like `input`, `general`, `misc`, `xwayland`:
  https://wiki.hypr.land/Configuring/Variables/
- Keybind syntax and flags:
  https://wiki.hypr.land/Configuring/Binds/
- Window rules:
  https://wiki.hypr.land/Configuring/Window-Rules/

## Notes on style

- Keep comments operational, not generic.
- Prefer short rationale over copied wiki paragraphs.
- Keep the actual wiki in the wiki; keep the local file focused on what matters
  for this Margine setup.
