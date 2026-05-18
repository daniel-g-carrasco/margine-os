# 2026-05-14 - Hyprland Lua migration plan

## Scope

Hyprland 0.55 introduced Lua configuration support, but Margine still treats
the Hyprlang `~/.config/hypr/hyprland.conf` tree as the production baseline.
This audit defines the guardrails before any `hyprland.lua` payload is allowed
into the installed desktop.

## Current decision

Production remains Hyprlang for now:

- `files/home/.config/hypr/hyprland.conf` is the entrypoint;
- the session wrapper starts Hyprland with `--config "$config_path"`;
- bootstrap, repair, and runtime validators still verify the Hyprlang path;
- `files/home/.config/hypr/hyprland.lua` must not appear in the baseline by
  accident.

The static installation validator fails if `hyprland.lua` appears unless the
repository also adds an explicit migration switch:

```text
files/home/.config/hypr/margine-hyprland-config-mode.env
MARGINE_HYPRLAND_CONFIG_MODE=lua
```

That switch is not present today. Adding it is not enough by itself; the same
change must also update the launcher and validators so they intentionally
select and verify the Lua config path.

## Migration gates

Before switching production defaults, validate the Lua path in a disposable VM:

- translate the current include order from `hyprland.conf` and `conf.d/*.conf`;
- preserve the descriptor-scoped Framework 13 ICC monitor rule;
- preserve Walker, Fuzzel fallback, portals, Waybar, hypridle, WSF, privacy
  indicators, screenshot and screen-recording helpers, and safe session actions;
- keep removed or rejected Hyprland options such as `dwindle:pseudotile` out of
  the translated config;
- update `margine-start-hyprland`, `bootstrap-in-chroot`,
  `repair-zfs-root-desktop-session`, and `validate-runtime-baseline` to respect
  `MARGINE_HYPRLAND_CONFIG_MODE=lua`;
- run the static repository checks and installed runtime validation;
- reboot and collect QEMU validation logs after applying the VM-only payload.

## Translation workbench

The first translation pass lives outside the active Hyprland config path:

```text
files/home/.config/hypr-lua-lab/hyprland.lua
files/home/.config/hypr-lua-lab/margine/*.lua
```

The workbench mirrors the production include order and keeps the generated theme
override as a separate Lua module so it can continue to override the base
look-and-feel module. It translates:

- monitor rules, including the descriptor-scoped Framework 13 ICC profile;
- environment variables and XWayland zero-scaling;
- `exec-once` startup behavior through the `hyprland.start` event;
- gaps, borders, opacity, blur, animation curves, layout defaults, misc, and
  ecosystem settings;
- keyboard, touchpad, gesture, and device settings;
- descriptive app/workspace/window/media/session binds through `hl.bind()`;
- layer and window rules, including the REAPER opacity workaround.

Known validation limits:

- static validation only proves Lua syntax, not Hyprland runtime type
  acceptance;
- key names, dispatcher shape, monitor ICC loading, and startup event behavior
  still need VM execution through `Hyprland --config ~/.config/hypr-lua-lab/hyprland.lua`;
- the production `files/home/.config/hypr/hyprland.lua` file remains forbidden
  until the migration switch and wrapper/validator support are added together.

## Acceptance signal

Lua can become the default only after the VM proves:

- greetd login reaches Hyprland;
- monitor rules and ICC load without config errors;
- Walker is warm and `SUPER+SPACE` works;
- Fuzzel fallback and `SUPER+ESC` session menu work;
- Waybar modules, privacy indicators, portals, screenshot, and recording paths
  still work;
- root-on-ZFS rollback validation still passes after an update.

Until then, `hyprland.lua` is an experiment, not a baseline file.
