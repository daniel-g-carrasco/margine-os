# Margine Waybar Guide

This directory owns the top bar for the Hyprland desktop.

## File map

- `config.jsonc`
  Module order, Waybar options, and module configuration blocks.
- `style.css`
  Visual presentation only.
- `theme-generated.css`
  Generated core palette rendered from `~/.config/margine/theme.env`.
- `launch.sh`
  Restart Waybar with the versioned config and write logs to `~/.cache/waybar.log`.
- `toggle.sh`
  Turn the bar off or on.
- `restart-swaync.sh`
  Restart swaync in a Hyprland-safe way when Waybar needs notification state to recover.

## Ownership split

- `config.jsonc` decides what appears on the bar and in what order.
- `style.css` decides how those modules look.
- `theme-generated.css` owns the shared palette tokens consumed by `style.css`.
- `~/.local/bin/*status` scripts decide the JSON payload for `custom/*` modules.

## Module map

- Left:
  `hyprland/workspaces`, `hyprland/window`
- Center:
  `clock`
- Right:
  `tray`, recording, VPN, split-lock, network, bluetooth, keep-awake, EasyEffects, audio, battery, notifications

## Common edit recipes

### Add a new custom module

1. Add it to `modules-left`, `modules-center`, or `modules-right` in `config.jsonc`.
2. Add a module block in `config.jsonc`.
3. Add CSS for its selector in `style.css`.
4. If needed, create or update the backing script in `~/.local/bin`.

Example:

```jsonc
"custom/example": {
  "format": "{}",
  "return-type": "json",
  "exec": "~/.local/bin/example-status",
  "interval": 5
}
```

Selector:

```css
#custom-example { }
```

### Change module order

Edit:

- `config.jsonc`

Keep the left / center / right arrays easy to scan. Prefer one item per line.

### Network module actions

The `custom/network` module deliberately exposes two different entry points:

- left click: `~/.local/bin/open-network-settings`
- middle click: `~/.local/bin/open-network-tui --nmtui`

`--nmtui` matters because the generic network wrapper can otherwise choose
`impala` or `nm-connection-editor` depending on device state. The middle click
path is reserved for operators who explicitly want the older `nmtui` terminal
UI.

### Change colors, spacing, or typography

Edit:

- `~/.config/margine/theme.env` for shared palette changes
- `style.css` for module-local layout and spacing

Touch the palette tokens first, then module-specific rules.

### Restart safely after edits

```bash
~/.config/waybar/launch.sh
tail -n 50 ~/.cache/waybar.log
```

## Notes on style

- Keep comments operational.
- Keep behavior in JSONC and helpers, not in CSS.
- Keep visual changes separate from structural/module-order changes when possible.
