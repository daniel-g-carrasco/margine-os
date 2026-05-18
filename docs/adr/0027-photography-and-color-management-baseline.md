# ADR 0027 - Baseline photography and color management

## State

Accepted

## Context

`Margine` was also born as a photographic workstation.

This means that the project must explain at least four levels:

- RAW development and photographic workflow;
- application color management;
- display calibration/profiling;
- management of ICC assets produced by the user.

Furthermore, on `Hyprland`, today there is also a real possibility of applying a
ICC profile directly at composer level.

This opens up an important architectural question:

- the color profile must be imposed by the composer;
- or it is better to start from the system (`colord`) and the applications that know about it
really handle it.

## Decision

For `Margine v1` the photography and color management baseline is:

- `darktable`
- `argyllcms`
- `displaycal`
- `colord`

plus a small library of user ICC profiles versioned in the repo as they are
stable and recognized as "good".

Furthermore, `Margine v1` adopts an explicit profile enforcement model:

- `colord` as source of truth for display profiles;
- color-managed applications as the first point of real profile application;
- `Hyprland` compositor-level ICC enabled only for explicitly validated monitor
  descriptors and profiles.

## Specific choices

### 1. Darktable

`Darktable` remains the main photographic tool.

The versioned baseline includes:

- lightweight and stable setup;
- a curated `darktablerc` baseline, limited to UI/OpenCL preferences
  riproducibili;
- user styles;
- no database library or cache.

`Darktable` is also the main reference for the display profile part:
when the system correctly exposes the display profile, it is the application a
do the color transformation where it is really needed.

### 2. ArgyllCMS e DisplayCAL

They are used for:

- misurare;
- calibrare;
- profilare;
- verificare.

However, they are not transformed into a "magical" self-configuration system.

### 3. Colord

`colord` enters the baseline as a system service for color profiles.

This is also consistent with the `darktable` documentation, which on Linux
queries the system and `colord` to find the correct display profile.

The same `darktable` documentation also reminds you that a display profile
poor quality can do more damage than a simple `sRGB`, so `Margine` preserves
only the profiles that we consider truly validated.

### 4. User ICC profiles

Validated and useful ICC profiles can be versioned as assets.

For `Margine v1` this applies to:

- the profile of the internal panel Framework 13;
- the Dell external monitor profile `P2415Q`.

However, they are not versioned:

- log `DisplayCAL`;
- measurement reports;
- database `colord`;
- old or experimental profiles;
- opaque runtime bindings like `DisplayCAL.ini` or `color.jcnf`.

### 5. Hyprland ICC

`Hyprland` 0.55 has a usable per-monitor ICC path. `Margine` enables it only
when the rule is pinned to a validated monitor descriptor and a versioned
profile asset.

Current default:

```conf
monitor = desc:BOE NE135A1M-NY1, preferred, 0x0, 2.0, icc, /usr/share/margine/icc/FW13_D65_GNOME_COLORS.icc
```

Reason for descriptor scoping:

- the `FW13_D65_GNOME_COLORS.icc` profile is the selected GNOME Colors /
  `colord-session` profile for this Framework 13 BOE panel, title `FW13 D65`;
- it is a display RGB ICC v2.2 profile with simple matrix/TRC structure, TRC
  gamma `2.06640625`, and a 3-channel, 256-entry, 16-bit `vcgt`;
- connector names such as `eDP-1` are less safe than the EDID description for
  applying calibration profiles;
- a future machine with a different internal panel must fall back to the generic
  monitor rule until its own profile is validated.

The `FW13_140cd_D65_2.2_S.icc` DisplayCAL/Argyll profile remains a preserved
asset, but it is not the Hyprland default: it is a different, complex
`XYZLUT+MTX` profile and weighs about 1.1 MB.

Reason for still being conservative:

- it's a powerful lever, but it changes the behavior of the entire graphics session;
- on `Hyprland` the ICC composer-level forces `sRGB` for `sdr_eotf` and overwrites
the CM preset of the monitor;
- the same documentation `Hyprland` reports that ICC and HDR/gaming are not one
peaceful combination.

For this reason the `v1` rule is:

- system and app first;
- then compositor ICC only for validated `desc:` monitor matches.

### 6. Browsers and other graphical applications

For `Margine v1` we do not introduce aggressive tweaks or browser-specific hacks for
color management.

The baseline remains this:

- install applications that already support color management well;
- bring out the correct profile from the system;
- avoid hidden settings that are difficult to maintain.

In practice:

- `darktable` and photography applications are the first target;
- the browser remains color-managed at the application level, but without policies
specials dedicated to the ICC in `v1`.

## Limite explicit

`Margine v1` promises compositor-level ICC only for the validated Framework 13
BOE panel rule above. It does not promise automatic ICC assignment for every
monitor, external display, HDR path, or gaming/fullscreen path.

The baseline instead focuses on:

- ICC assets preserved;
- correctly installed color-managed apps;
- base solida per usare `darktable`, soft-proof e profiling;
- a validated, descriptor-scoped path for `Hyprland` ICC.

## Consequences

### Positive

- the system is already born with the correct photographic stack;
- good ICC profiles are not lost;
- the project avoids fragile or opaque color automations;
- the compositor profile is applied where we have validated hardware identity.

### Negative

- the final assignment of profiles for new displays remains a conscious phase;
- some calibrations remain linked to the real hardware context;
- HDR, screencopy, fullscreen and direct-scanout behavior still need dedicated
  regression checks after Hyprland upgrades.

## For a student

The crucial difference here is:

- it's one thing to have the right profiles and tools;
- another is deciding where to apply them;
- yet another is not to confuse the entire system with a single app.

`Margine` chooses the prudent path:

- preserve valid assets;
- prepare the correct stack;
- starting from applications that really support color management;
- enable the composer's ICC only after the profile and monitor match have been
  properly validated.
