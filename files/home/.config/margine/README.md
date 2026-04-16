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

Operational rule:

- edit `theme.env`
- regenerate derived repo artifacts
- re-apply provisioning on the host

Current generator:

- `/home/daniel/dev/margine-os/scripts/render-theme-artifacts`
