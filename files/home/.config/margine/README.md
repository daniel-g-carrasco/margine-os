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
- HyprToolkit palette
- Waybar palette import
- SwayNC palette import
- Kitty color include

Hyprland-specific note:

- `MARGINE_THEME_HYPR_ACTIVE_BORDER_PRIMARY` and `...SECONDARY` let you keep
  Hyprland borders independent from the desktop accent palette
- set both to the same value for a solid border instead of a gradient
- `MARGINE_THEME_HYPR_WINDOW_ROUNDING='0'` gives square window corners

Operational rule:

- edit `theme.env`
- regenerate derived repo artifacts
- re-apply provisioning on the host

Current generator:

- `/home/daniel/dev/margine-os/scripts/render-theme-artifacts`
