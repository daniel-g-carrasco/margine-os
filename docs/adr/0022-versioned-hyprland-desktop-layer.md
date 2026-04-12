# ADR 0022 - Desktop layer Hyprland versioned e riproducibile

## State

Accepted

## Problema

Up to this point `Margine` already had:

- package manifests;
- il bootstrap;
- il login path;
- some isolated runtime fixes.

However, the most important piece for everyday experience was missing: a truth
desktop layer versioned.

Without this layer, the project installs the right packages but does not rebuild
truly the system that the user uses every day.

## Decision

`Margine v1` releases a complete user desktop layer based on:

- `Hyprland`
- `hypridle`
- `hyprlock`
- `hyprpaper`
- `waybar`
- `mako`
- `walker`
- `satty`
- `swayosd`
- helper script under `~/.local/bin`

This layer is installed by a dedicated provisioner, separate from the
system provisioner.

## What goes into the layer

Entrano:

- i file `~/.config/hypr/*`;
- i file `~/.config/waybar/*`;
- the config `mako`;
- the config `walker`;
- the config `satty`;
- the style `swayosd`;
- i wrapper locali per launcher, screenshot, recording, OSD, rete e Bluetooth.

However, they do not enter:

- user's personal wallpapers;
- cache;
- runtime databases;
- transient local state.

## Launcher

The chosen baseline is:

- `walker` as preferred launcher;
- `hyprlauncher` as official fallback;
- wrapper `margine-launcher` as single point of invocation.

This allows the desktop to remain consistent even when `walker` is not
installed or is disabled.

## Screenshot e recording

The project maintains the screenshot/recording workflow currently validated on
real car:

- screenshot con menu coerente al launcher;
- annotation with `satty`;
- recording with indicator `REC` in `waybar`;
- OSD volume/brightness with `swayosd`.

The `v1` baseline directly uses:

- `grim`
- `slurp`
- `satty`
- `wf-recorder`

This prevents the desktop from depending on an AUR wrapper for basic functions like
screenshot e recording.

## Wallpaper

The project does not copy a personal wallpaper.

`Margine` instead installs a neutral default asset underneath
`/usr/share/margine/wallpapers`, like this:

- bootstrapping always produces a complete desktop;
- the repository does not include private images;
- the user wallpaper can be changed later without dirtying the baseline.

## Implementation v1

`Margine` version:

- the desktop files under `files/home/.config`
- the helpers under `files/home/.local/bin`
- a wallpaper asset under `files/usr/share/margine`
- a dedicated provisioner that installs everything for the end user

The `chroot` bootstrap calls this provisioner after user provisioning e
before hardware-specific optional layers.

## Practical consequences

This decision gives `Margine`:

- un desktop realmente riproducibile;
- less dependency on manual copies of dotfiles;
- a clear boundary between system and user session;
- a concrete base to refine without losing control of the project.

## For a student: the simple version

Installing packages is not enough.

A real desktop is born when you put three things together:

- the right programs;
- the right configuration files;
- the little scripts that hold the experience together.

This ADR says just that: the desktop is not a detail. It's a layer.
