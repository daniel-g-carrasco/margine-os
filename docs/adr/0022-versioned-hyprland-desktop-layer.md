# ADR 0022 - Versioned and reproducible Hyprland desktop layer

## State

Accepted

## Problem

Up to this point `Margine` already had:

- package manifests;
- bootstrap orchestration;
- a defined login path;
- some isolated runtime fixes.

However, the most important piece for the everyday experience was still missing:
a versioned desktop layer that could be rebuilt from the repository.

Without that layer, the project could install the right packages but still fail
to reproduce the actual user experience used every day.

## Decision

`Margine v1` ships a complete user desktop layer based on:

- `Hyprland`
- `hypridle`
- `hyprlock`
- `hyprpaper`
- `waybar`
- `mako`
- `walker`
- `satty`
- `swayosd`
- helper scripts under `~/.local/bin`

This layer is installed by a dedicated provisioner, separate from the system
provisioner.

## What goes into the layer

Included:

- `~/.config/hypr/*`
- `~/.config/waybar/*`
- the `mako` configuration
- the `walker` configuration
- the `satty` configuration
- the `swayosd` style
- local wrappers for launcher, screenshots, recording, OSD, network, Bluetooth,
  and lockscreen behavior

Explicitly not included:

- personal wallpapers
- cache
- runtime databases
- transient local state

## Launcher

The chosen baseline is:

- `walker` as the preferred launcher
- `fuzzel` as the official fallback
- `margine-launcher` as the single invocation point

This keeps the desktop coherent even when `walker` is unavailable or disabled.

## Screenshots and recording

The project versions the screenshot and recording workflow validated on real
hardware:

- launcher-consistent screenshot menu
- annotation with `satty`
- recording with a `REC` indicator in `waybar`
- volume and brightness OSD through `swayosd`

The `v1` baseline directly uses:

- `grim`
- `slurp`
- `satty`
- `wf-recorder`

This avoids depending on an AUR wrapper for basic screenshot and recording
features.

## Wallpaper

The project does not copy a personal wallpaper.

`Margine` instead installs a neutral default asset under
`/usr/share/margine/wallpapers`, so that:

- bootstrapping always produces a complete desktop
- the repository does not include private images
- the user wallpaper can be changed later without dirtying the baseline

## Hyprlock runtime scaling

`hyprlock` is not treated as a static dotfile only.

The versioned desktop layer contains:

- a base template at `~/.config/hypr/hyprlock.conf`
- a runtime wrapper at `~/.local/bin/margine-hyprlock`

The wrapper is the effective entrypoint used by:

- the explicit lock binding
- `hypridle`
- the login flow that enters the session and immediately locks it

At every lock invocation, the wrapper:

1. reads monitor data from `hyprctl -j monitors`
2. selects the focused monitor, falling back to the first known monitor
3. converts raw monitor geometry to logical geometry (`width / scale`,
   `height / scale`)
4. computes clamped font sizes, input size, accent line width, and vertical
   offsets from that logical geometry
5. anchors the layout around the authentication cluster instead of scaling each
   widget independently
6. writes a temporary generated config and launches `hyprlock -c <generated>`

This design exists because `hyprlock` does not natively provide the kind of
layout constraints Margine needs, such as:

- practical min/max behavior for the password field
- safe margins from the screen edges
- spacing rules between the fingerprint prompt and failure label
- stable scaling across HiDPI laptops and low-resolution virtual machines

The source of truth remains versioned:

- the template owns the visual structure and marker positions
- the wrapper owns the monitor-aware runtime calculations

## Implementation

`Margine` versions:

- desktop files under `files/home/.config`
- helpers under `files/home/.local/bin`
- a wallpaper asset under `files/usr/share/margine`
- a dedicated provisioner that installs the desktop payload for the end user

The chroot bootstrap calls this provisioner after user provisioning and before
hardware-specific optional layers.

## Practical consequences

This decision gives `Margine`:

- a reproducible desktop instead of a package-only install
- less dependency on manual dotfile copies
- a clear boundary between system state and user-session state
- a controlled place to evolve visual behavior such as dynamic `hyprlock`
  scaling

## For a student: the simple version

Installing packages is not enough.

A real desktop comes from three things together:

- the right programs
- the right configuration files
- the small scripts that hold the experience together

This ADR says exactly that: the desktop is not a detail. It is a real product
layer.
