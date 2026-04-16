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
- `hyprlock.conf`
  Lockscreen template consumed by the `margine-hyprlock` wrapper.
- `hyprpaper.conf`
  Static wallpaper source of truth for the hyprpaper daemon.
- `hyprlauncher.conf`
  Launcher UX defaults: focus, cache, finders, window size.
- `~/.local/bin/margine-hyprlock`
  Runtime generator that scales and renders the hyprlock template.
- `~/.local/bin/launch-hyprpaper`
  Startup wrapper for the hyprpaper daemon.
- `~/.local/bin/hypr-workspace-layout`
  Login-time workspace placement policy across monitors.
- `conf.d/10-variables.conf`
  Modifier aliases and launcher variables like `$terminal` and `$browser`.
- `conf.d/20-autostart.conf`
  `exec-once` session startup programs and daemons.
- `conf.d/30-environment.conf`
  Environment variables and XWayland behavior.
- `conf.d/40-look-and-feel.conf`
  Gaps, borders, decoration, blur, animation, layout defaults.
- `conf.d/45-theme-generated.conf`
  Generated window-border and rounding overrides rendered from `~/.config/margine/theme.env`.
- `conf.d/50-input.conf`
  Keyboard, touchpad, gestures, and device overrides.
- `conf.d/60-binds.conf`
  All Hyprland binds in one file: apps, session, windows, workspaces, media.
- `conf.d/70-rules.conf`
  `layerrule`, `windowrule`, and placement policy.

## Common edit recipes

### Add or change an app shortcut

Edit:

- `conf.d/10-variables.conf` if you need a new `$variable`
- `conf.d/60-binds.conf` for the actual bind

Example:

```ini
$editor = kitty -e nvim
bind = $mainMod, E, exec, $editor
```

For binds that should be self-documenting in `hyprctl binds`, prefer:

```ini
bindd = $mainMod, E, Open editor, exec, $editor
```

`conf.d/60-binds.conf` is intentionally ordered for human scanning:

1. daily use: launchers and helpers
2. workspaces
3. window/layout actions
4. screenshots and media
5. session/destructive actions

When adding a new bind, place it in the nearest existing section instead of
creating micro-sections.

### Add a new startup daemon

Edit:

- `conf.d/20-autostart.conf`

Use `exec-once` when the process should start exactly once per login.

### Change gaps, borders, blur, or animation speed

Edit:

- `conf.d/40-look-and-feel.conf`
- `~/.config/margine/theme.env` if the change is really part of the shared visual baseline

If the goal is to change the active/inactive border palette, border thickness,
or global window rounding, start from `~/.config/margine/theme.env` and
re-render the generated theme artifacts.

### Change keyboard or touchpad behavior

Edit:

- `conf.d/50-input.conf`

For hardware-specific overrides, prefer a `device { ... }` block instead of
changing the global `input` defaults.

### Add a new workspace shortcut

Edit:

- `conf.d/60-binds.conf`

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

### Change lockscreen look or structure

Edit:

- `~/.config/margine/theme.env` for centralized palette and shared squareness
- `hyprlock.conf` for static visuals and widget ordering
- `~/.local/bin/margine-hyprlock` for dynamic scaling and placement logic

Do not edit `@margine_*` markers casually. They are owned by the wrapper.

### Change wallpaper behavior

Edit:

- `hyprpaper.conf` for wallpaper source and fit mode
- `~/.local/bin/launch-hyprpaper` for process startup policy

### Change launcher size or finder behavior

Edit:

- `hyprlauncher.conf`

### Change dynamic lockscreen scaling or monitor selection

Edit:

- `~/.local/bin/margine-hyprlock`

Use the dry-run mode before testing visually:

```bash
~/.local/bin/margine-hyprlock --margine-hyprlock-dry-run
```

### Change startup wallpaper process behavior

Edit:

- `~/.local/bin/launch-hyprpaper`

### Change which workspace lands on which monitor at login

Edit:

- `~/.local/bin/hypr-workspace-layout`

### Add a new screenshot, volume, or media shortcut

Edit:

- `conf.d/60-binds.conf`

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
