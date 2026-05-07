## Margine Theme Baseline

`theme.env` is the single source of truth for the shared desktop theme baseline.

It currently drives:

- GTK3 theme
- GTK4 theme baseline
- generated GTK4/libadwaita CSS derived from a Rewaita export
- GNOME / GTK session defaults applied through `gsettings`
- icon theme
- Qt / KDE icon theme override
- UI font
- accent color
- generated Margine icon overlay
- Breeze Dark Qt/KDE icon fallback on dark sessions
- managed Firefox theme install
- Hyprland window border colors and rounding
- Hyprlock palette, blur treatment, fonts, and input rounding
- HyprToolkit palette
- qt5ct color schemes for Qt5 apps
- hyprqt6engine + qt6ct color data for Qt6 / KDE apps outside Plasma
- Waybar palette import
- Walker palette and launcher font
- Fuzzel fallback launcher and dmenu picker theme
- NMTUI terminal color map
- SwayNC palette import
- SwayOSD palette and rounding
- Kitty color include
- versioned theme presets under `~/.config/margine/themes`

Hyprland-specific note:

- `MARGINE_THEME_HYPR_ACTIVE_BORDER_PRIMARY` and `...SECONDARY` let you keep
  Hyprland borders independent from the desktop accent palette
- set both to the same value for a solid border instead of a gradient
- `MARGINE_THEME_HYPR_WINDOW_ROUNDING='0'` gives square window corners

Hyprlock-specific note:

- the `MARGINE_THEME_HYPRLOCK_*` block controls the lockscreen layer that is
  intentionally separate from the normal Hyprland window border logic
- use `..._FONT_UI` and `..._FONT_MONO` to keep the lockscreen typography in
  sync with the rest of the desktop without editing `hyprlock.conf`
- use the `..._ALPHA` values when the lockscreen should feel softer or more
  contrasted without changing the shared base colors in the main palette
- use the blur/noise/contrast/brightness knobs when the screenshot background
  feels too busy, too muddy, or too bright

Launcher-specific note:

- `MARGINE_THEME_LAUNCHER_FONT_NAME` feeds both the Walker theme import and the
  generated Fuzzel font stack
- the launcher sizing knobs feed Fuzzel directly and let you keep screenshot /
  recording pickers compact without editing scripts

NMTUI-specific note:

- `nmtui` cannot use the desktop hex palette directly; it only accepts named
  terminal colors
- the `MARGINE_THEME_NMTUI_*` block exists to keep it aligned with the desktop
  while making that limitation explicit

Icon-theme note:

- GTK/GNOME uses the generated `Margine-Adwaita` icon theme by default
- that overlay keeps Adwaita / hicolor as the app icon baseline
- Margine-specific launchers are explicitly assigned icons inside the overlay
- MoreWaita is selectively layered for `MimeTypes`, `Devices`, and extra
  `Places`; its `Apps` catalog is not imported wholesale
- `MARGINE_THEME_ICON_FOLDER_COLOR` selects the folder variant source from the
  installed `Adwaita-*` color themes without changing the rest of the app icons
- selected Adwaita folder colors override matching MoreWaita place names so
  folder tint remains controlled by `theme.env`
- MoreWaita `Legacy` remains opt-in through explicit Margine launcher icon
  candidates instead of being imported as a whole context
- Qt/KDE stays on `MARGINE_THEME_QT_ICON_THEME`, which should usually remain
  `breeze-dark` on dark sessions

Rewaita note:

- the default Margine GTK4/libadwaita CSS is derived from a Rewaita export,
  but Rewaita itself is not required at runtime
- Margine vendors the exported baseline as a template and regenerates `gtk.css`
  from `theme.env`, so presets stay deterministic
- the default baseline is derived from the `Margine V2` Rewaita export and
  intentionally does not append a sharp-border override because that caused
  rendering issues in GTK/libadwaita apps
- `MARGINE_THEME_GTK4_ACCENT_BG` keeps the Rewaita accent background explicit
  so it is not collapsed into the libadwaita named accent color
- GTK4/libadwaita backdrop colors are generated explicitly because some apps
  otherwise fall back to light inactive-window colors even when the active
  window is dark
- Rewaita remains useful as an authoring tool if you want to design a new GTK4
  baseline and re-export it, but it is no longer a required dependency

Browser accent note:

- Firefox's managed libadwaita theme follows the GNOME named accent exposed by
  `MARGINE_THEME_ACCENT_COLOR`
- the default preset uses `yellow`, the closest standard libadwaita accent to
  Margine's muted amber palette
- Thunderbird is kept on `accent-color` so browser and mailer follow the same
  OS accent channel instead of carrying a hardcoded orange override

Operational rule:

- edit `theme.env`
- run `~/.local/bin/margine-apply-theme`

Preset rule:

- the active file remains `~/.config/margine/theme.env`
- reusable snapshots live under `~/.config/margine/themes/*.env`
- use `margine-apply-theme --preset NAME` or the `Themes` launcher when you
  want to switch the full palette quickly

What `margine-apply-theme` does:

- optionally rewrites the active `theme.env` from a named preset
- mirrors `~/.config/margine/theme.env` into the public repo first
- regenerates derived theme artifacts needed by the live session
- copies generated runtime files back onto the host
- reapplies GTK / GNOME session defaults
- reloads Hyprland, Waybar, SwayNC and SwayOSD before non-critical mirror work
- mirrors the same theme into the personal repo after the visible refresh
- refreshes generated Fuzzel theme colors for launcher and picker menus
- refreshes the generated `nmtui` palette file
- refreshes generated qt5ct / qt6ct palette files for Qt apps
- refreshes generated hyprqt6engine theme data for Qt6 / KDE apps
- refreshes the generated Margine icon overlay and icon cache when a generated
  icon theme is active
- updates the lockscreen theme source indirectly, so the next `hyprlock`
  invocation picks up the new palette, fonts, and blur tuning

What it does not do:

- it does not touch root-managed files under `/etc`
- if you changed the Firefox or Thunderbird managed theme policy, re-run:
  `sudo ${MARGINE_PUBLIC_REPO:-/usr/local/lib/margine}/scripts/provision-user-app-config --username $USER`

Current generator:

- `${MARGINE_PUBLIC_REPO:-/usr/local/lib/margine}/scripts/render-theme-artifacts`

Preset launcher:

- `~/.local/bin/margine-theme-menu`
- desktop entry: `Themes`
