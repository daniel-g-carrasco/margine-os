## Margine Theme Baseline

`theme.env` is the single source of truth for the shared desktop theme baseline.

It currently drives:

- GTK3 theme
- GTK4 theme baseline
- GNOME / GTK session defaults applied through `gsettings`
- icon theme
- UI font
- accent color
- Papirus folder tint
- managed Firefox theme install
- Hyprland window border colors and rounding
- Hyprlock palette and input rounding
- HyprToolkit palette
- Waybar palette import
- Walker palette
- Fuzzel fallback launcher and dmenu picker theme
- SwayNC palette import
- SwayOSD palette and rounding
- Kitty color include

Hyprland-specific note:

- `MARGINE_THEME_HYPR_ACTIVE_BORDER_PRIMARY` and `...SECONDARY` let you keep
  Hyprland borders independent from the desktop accent palette
- set both to the same value for a solid border instead of a gradient
- `MARGINE_THEME_HYPR_WINDOW_ROUNDING='0'` gives square window corners

Operational rule:

- edit `theme.env`
- run `~/.local/bin/margine-apply-theme`

What `margine-apply-theme` does:

- mirrors `~/.config/margine/theme.env` into the public and personal repos
- regenerates derived theme artifacts in the repos
- copies generated runtime files back onto the host
- reapplies GTK / GNOME session defaults
- reloads Hyprland, Waybar, SwayNC and SwayOSD
- refreshes generated Fuzzel theme colors for launcher and picker menus

What it does not do:

- it does not touch root-managed files under `/etc`
- if you changed Papirus folder tint or Firefox managed theme policy, re-run:
  `sudo /home/daniel/dev/margine-os/scripts/provision-user-app-config --username $USER`

Current generator:

- `/home/daniel/dev/margine-os/scripts/render-theme-artifacts`
