# Margine Hyprland Lua Lab

This directory contains the Hyprland 0.55 Lua translation workbench.

It is intentionally not installed as `~/.config/hypr/hyprland.lua`. The
production session still starts `~/.config/hypr/hyprland.conf` until the
migration switch, wrapper support, and VM validation are complete.

The module order mirrors the production Hyprlang include order:

1. `margine/monitors.lua`
2. `margine/variables.lua`
3. `margine/environment.lua`
4. `margine/autostart.lua`
5. `margine/look_and_feel.lua`
6. `margine/theme_generated.lua`
7. `margine/input.lua`
8. `margine/binds.lua`
9. `margine/rules.lua`

Smoke-test syntax without activating the config:

```bash
find ~/.config/hypr-lua-lab -name '*.lua' -print0 | xargs -0 -n1 luac -p
```

Runtime validation must happen in a disposable VM with Hyprland launched through
an explicit `--config ~/.config/hypr-lua-lab/hyprland.lua` test path.
