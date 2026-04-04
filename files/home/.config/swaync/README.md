# swaync notes

`config.json` must stay valid JSON, so comments are not allowed inside it.

Use this file as the annotation layer for the keys that matter most.

## Geometry

- `control-center-width`
  Width of the notification panel.
- `control-center-margin-top`
  Gap between the panel and the top edge / Waybar.
- `control-center-margin-right`
  Gap from the right screen edge.
- `notification-window-width`
  Width of popup notifications shown while the panel is closed.

## Behavior

- `transition-time`
  swaync's own notification animation duration.
- `timeout`
  Auto-dismiss time for popup notifications.
- `notification-grouping`
  `false` keeps notifications in a flat list.
- `fit-to-screen`
  When `false`, the panel is allowed to size itself instead of stretching.

## Top widgets

- `widgets`
  Order of sections in the control center.
- `widget-config.notifications.vexpand`
  Keeps the notifications block from stretching vertically.
- `widget-config.mpris.*`
  Media card behavior.

## Styling

Almost all visual adjustments belong in `style.css`, not here.

Start from these knobs in `style.css`:

- `--panel-padding`
- `--section-gap`
- `--panel-card-gap`
- `--popup-card-gap`
- `--popup-edge-gap`
- `--content-padding-x`
- `--content-padding-y`
