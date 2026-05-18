# 2026-05-14 - Hyprland ICC validation for the Framework 13 panel

## Context

Daniel originally tested the DisplayCAL/Argyll profile, then corrected the
Margine baseline on 2026-05-16 to the GNOME Colors / `colord-session` profile
selected on the host.

Current baseline profile:

```text
/home/daniel/.local/share/icc/BOE NE135A1M-NY1 (high) 2025-12-24 17-14-39 i1-display3.icc
```

Repository stable name:

```text
/usr/share/margine/icc/FW13_D65_GNOME_COLORS.icc
```

Primary reference:
<https://wiki.hypr.land/Configuring/Basics/Monitors/>

Hyprland 0.55 supports per-monitor ICC through the monitor rule:

```conf
monitor = OUTPUT, preferred, POS, SCALE, icc, /absolute/path/profile.icc
```

The ICC path must be absolute. When `icc` is set, Hyprland uses that profile
instead of the monitor `cm` preset.

## Profile findings

The selected `FW13 D65` profile is suitable for Hyprland loading:

- ICC v2.2 display profile;
- RGB color space;
- GNOME Colors / `colord-session` origin metadata;
- simple matrix/TRC profile;
- TRC gamma `2.06640625`;
- device model metadata `NE135A1M-NY1`;
- mapped by colord to `xrandr-BOE-NE135A1M-NY1-0x00000000`;
- `vcgt` is a 3-channel, 256-entry, 16-bit table;
- size is about 70 KB.

The former `FW13_140cd_D65_2.2_S.icc` profile is not the default Hyprland
profile. It is a different DisplayCAL/Argyll `XYZLUT+MTX` profile and is about
1.1 MB.

The profile is not generic. It describes Daniel's Framework 13 BOE panel and
must not be applied to arbitrary internal panels.

## Host validation

Detected host monitor:

```text
output: eDP-1
description: BOE NE135A1M-NY1
mode: 2880x1920@120
scale: 2.0
```

Live Hyprland application command:

```bash
hyprctl keyword monitor 'desc:BOE NE135A1M-NY1, preferred, 0x0, 2.0, icc, /home/daniel/.local/share/icc/BOE NE135A1M-NY1 (high) 2025-12-24 17-14-39 i1-display3.icc'
```

Result:

```text
ok
```

No immediate Hyprland monitor-rule error was emitted.

## Margine implementation

Margine now installs ICC profiles in two places:

- user-facing legacy/application path:
  `~/.local/share/icc/margine/*.icc`;
- system baseline path:
  `/usr/share/margine/icc/*.icc`.

The default Hyprland monitor rule is descriptor-scoped:

```conf
monitor = desc:BOE NE135A1M-NY1, preferred, 0x0, 2.0, icc, /usr/share/margine/icc/FW13_D65_GNOME_COLORS.icc
```

The generic fallback remains:

```conf
monitor = , preferred, auto, auto
```

This means:

- the validated Framework 13 BOE panel gets the ICC profile;
- other panels do not receive this calibration accidentally;
- external monitors still rely on their own future explicit rules.

## Validation expectations

Fresh install or reprovisioned host:

```bash
test -f /usr/share/margine/icc/FW13_D65_GNOME_COLORS.icc
grep -n 'desc:BOE NE135A1M-NY1.*icc.*FW13_D65_GNOME_COLORS.icc' ~/.config/hypr/monitors.conf
hyprctl monitors all | sed -n '/Monitor eDP-1/,/^$/p'
```

The monitor descriptor must be `BOE NE135A1M-NY1`. If it is not, the ICC rule
must be considered intentionally inactive for that machine.

## Remaining risks

- Hyprland ICC is compositor-wide for that monitor and changes the whole
  graphical session.
- HDR/gaming/direct-scanout paths still need separate regression testing.
- Screenshot and color-picker interpretation can be affected by compositor
  color transforms.
- Future Hyprland upgrades must be tested because the color-management path is
  still evolving.
