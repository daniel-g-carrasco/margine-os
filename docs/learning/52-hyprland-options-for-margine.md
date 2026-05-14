# Hyprland options for Margine

Date: 2026-05-13

Sources:

- Hyprland variables: https://wiki.hypr.land/Configuring/Variables/
- Hyprland window rules: https://wiki.hypr.land/Configuring/Window-Rules/
- Hyprland workspace rules: https://wiki.hypr.land/Configuring/Workspace-Rules/
- Hyprland dispatchers: https://wiki.hypr.land/Configuring/Dispatchers/
- Hyprland gestures: https://wiki.hypr.land/Configuring/Gestures/
- Hyprland permissions: https://wiki.hypr.land/Configuring/Permissions/

## Scope

This note reviews the Hyprland configuration surface that can realistically
improve Margine. It is not a request to enable every interesting option. The
goal is to separate:

- options already appropriate for the baseline;
- low-risk candidates for the VM lab;
- options that are useful only under specific hardware or security conditions;
- options that should stay out of the default system.

Hyprland moves quickly. The online wiki documents the latest behavior, while a
running Margine system uses the installed Hyprland build. An option is safe for
the baseline only when the installed compositor accepts it.

## Runtime validation rule

Before adding or keeping a Hyprland option in Margine, validate it on the
installed version:

```sh
hyprctl descriptions > /tmp/hyprland-descriptions.txt
rg 'option_name|section_name' /tmp/hyprland-descriptions.txt
hyprctl reload
journalctl --user -b --no-pager | rg -i 'hyprland|config error|unknown|invalid'
```

For an individual option:

```sh
hyprctl getoption ecosystem:no_donation_nag
hyprctl getoption input:touchpad:disable_while_typing
```

Do not commit options that are present only in the wiki but missing from
`hyprctl descriptions` on the target Margine version. The previous
`dwindle:pseudotile` regression came from this exact class of problem.

## Already appropriate for Margine

### Upstream noise suppression

Current baseline:

- `ecosystem:no_update_news = true`
- `ecosystem:no_donation_nag = true`
- `misc:disable_hyprland_logo = true`

These are correct for an operating system. Margine should own boot, login and
desktop branding, and should not expose upstream donation or news popups after a
routine update.

Files:

- `files/home/.config/hypr/conf.d/40-look-and-feel.conf`

### Dwindle layout without removed options

Current baseline keeps:

- `general:layout = dwindle`
- `dwindle:preserve_split = true`

The old `dwindle:pseudotile` option must stay out of the baseline unless the
installed runtime exposes it again. It is not a general Margine requirement.

### Keyboard layout independent binds

Current baseline:

- `input:resolve_binds_by_sym = true`

This is useful because Margine is intended to work with non-US keyboard layouts.
It reduces fragile keybinding behavior when the active layout changes.

Files:

- `files/home/.config/hypr/conf.d/50-input.conf`

### Touchpad palm-rejection baseline

Current baseline:

- `input:touchpad:disable_while_typing = true`

This should remain standard. It does not replace libinput palm detection, but it
does prevent the most common accidental pointer movement while typing.

### Scroll speed ownership

Margine should keep static Hyprland `scroll_factor` commented out when Wayland
Scroll Factor is installed. WSF is the user-facing source of truth for scroll
speed, because it can coordinate vertical and horizontal scroll behavior and
apply changes live.

Files:

- `files/home/.config/hypr/conf.d/50-input.conf`
- package manifest entry for `wayland-scroll-factor`

### Workspace gestures

Current baseline:

- `gesture = 3, horizontal, workspace`

This is a reasonable default. Avoid destructive gestures by default. Workspace
switching is reversible and easy to understand.

### Variable refresh rate

Current baseline:

- `misc:vrr = 2`

Keep this guarded by real-world host and VM testing. VRR is useful on supported
panels but can be display-stack sensitive.

## Low-risk candidates for the VM lab

### Floating rules for constrained dialogs

Problem observed in Margine: GTK file choosers, NetworkManager dialogs and QEMU
dialogs can become too narrow when tiled. Internal widgets then compress instead
of respecting their natural minimum width.

Candidate behavior:

- float file chooser and transient utility dialogs;
- center them;
- apply a reasonable minimum or default size;
- avoid forcing ordinary application windows to float.

This belongs in window rules, not in global layout settings.

Candidate targets:

- file chooser dialogs from Firefox, Papers and GTK apps;
- `nm-connection-editor`;
- QEMU/virt-manager transient dialogs;
- authentication or confirmation dialogs.

Validation:

```sh
hyprctl clients
hyprctl reload
journalctl --user -b --no-pager | rg -i 'hyprland|windowrule|config error'
```

Files to inspect or extend:

- `files/home/.config/hypr/conf.d/70-window-rules.conf`

### Workspace rules for predictable roles

Workspace rules can make the desktop feel more like an OS and less like a bag of
applications. Candidate use:

- stable workspace names for terminal, browser, work, media or VM workflows;
- no special behavior for destructive actions;
- no hardcoded personal application assumptions in the public repo.

This is useful only if the defaults stay generic.

### Permission rules for sensitive compositor access

Hyprland exposes a permissions system for privileged compositor capabilities.
This is relevant for:

- screenshot and screen recording tools;
- global shortcut portals;
- input capture;
- automation tools.

Margine should prefer explicit permission rules over broad implicit trust, but
only after testing current portal behavior. This area can affect screen sharing,
recording and remote support.

### Cursor behavior

Useful candidates, only if present in the installed version:

- hide cursor while typing;
- hide cursor after inactivity;
- avoid cursor warps that make focus changes feel surprising.

These are quality-of-life changes, not boot-critical changes. Validate them on
the Framework touchpad and in QEMU.

### Dispatchers and binds

Potential improvements:

- predictable workspace cycle binds;
- explicit resize mode;
- direct dispatchers for power menu, recorder menu, launcher fallback and
  network editor.

Rule: destructive dispatchers must go through a confirmation layer. Shutdown,
reboot and logout entries must not execute directly from Walker or Fuzzel.

## Candidates requiring caution

### Render and experimental options

Render options can affect correctness, latency and GPU-specific behavior. Do not
ship broad changes without host and VM validation.

Examples to treat as lab-only:

- direct scanout behavior;
- explicit synchronization changes;
- experimental color management protocol toggles;
- global tearing behavior.

### XWayland scaling

Some XWayland options help legacy applications on fractional scaling, but they
can also make apps blurry or mis-sized. Keep them opt-in unless a real default
scaling problem is reproduced.

### Debug options

Debug options should not be part of the normal OS baseline. They are useful for
audits and temporary diagnostics only.

## Proposed adoption plan

### Baseline now

Keep:

- upstream noise suppression;
- layout-safe `dwindle` settings;
- keyboard symbol resolution;
- touchpad `disable_while_typing`;
- WSF-owned scroll speed;
- conservative workspace swipe;
- existing VRR setting after host/VM smoke testing.

### VM lab

Evaluate:

- dialog floating and centering rules;
- explicit Hyprland permissions for recorder and portal-sensitive tools;
- cursor hide behavior;
- workspace rules if they remain generic.

### Defer

Do not default-enable:

- broad render/experimental toggles;
- global tearing;
- XWayland scaling changes without a reproduced problem;
- debug-only settings;
- any option missing from `hyprctl descriptions`.

## Validation checklist

For each Hyprland change:

```sh
hyprctl descriptions > /tmp/hyprland-descriptions.txt
hyprctl reload
hyprctl getoption ecosystem:no_donation_nag
hyprctl getoption input:touchpad:disable_while_typing
journalctl --user -b --no-pager | rg -i 'hyprland|config error|unknown|invalid'
```

For UI behavior:

- open Walker;
- open Fuzzel fallback;
- open a GTK file chooser;
- open `nm-connection-editor`;
- open QEMU/virt-manager;
- switch workspace with keyboard and touchpad gesture;
- type in terminal while brushing the touchpad.

For packaging:

```sh
./scripts/validate-installation-pipeline
./scripts/check-shell-and-manifests
./scripts/check-bash-errexit-footguns
git diff --check
```

## Files that usually own these changes

- `files/home/.config/hypr/conf.d/40-look-and-feel.conf`
- `files/home/.config/hypr/conf.d/50-input.conf`
- `files/home/.config/hypr/conf.d/70-window-rules.conf`
- `files/home/.config/margine/theme.env`
- `scripts/render-theme-artifacts`

Keep compositor behavior in Hyprland files. Keep generated application styling
behind `theme.env` and `render-theme-artifacts`.
