# ADR 0013 - Manifest-driven package installation

## State

Accepted

## Why this ADR exists

Now that `Margine` has separate manifests for:

- base;
- hardware;
- security;
- desktop;
- app;
- font;
- AUR;
- Flatpak;

we need a coherent way to transform them into real installations.

## Problem to solve

If manifests remain just documentation, the project loses strength.

If, however, we use them without rules, we risk:

- mix official repos, AUR and Flatpak;
- lose the order of the layers;
- introduce difficult to read installations;
- make `Margine` difficult to maintain.

## Decision

For `Margine v1`, package installation will be manifest-driven.

This means:

1. official packages are read from versioned `*.txt` manifests;
2. the official layers have an explicit order;
3. a small baseline AUR enters the default path only where it is not needed
   break the target desktop;
4. Flatpak does not enter the default path;
5. Non-essential AUR and Flatpak exceptions are enabled only with flags
   explicit.

## Canonical order of official layers

The basic order is:

1. `base-system`
2. `hardware-framework13-amd`
3. `connectivity-stack`
4. `security-and-recovery`
5. `hyprland-core`
6. `toolkit-gtk-qt`
7. `desktop-integration`
8. `apps-core`
9. `apps-photo-audio-video`
10. `fonts`

## AUR rule

The `aur-baseline.txt` manifest is installed automatically.

Reason:

- `Margine` uses `walker` as preferred launcher;
- `walker` requires `elephant`;
- without these packages the installed desktop would be inconsistent with the
  declared baseline.

However, the `aur-exceptions.txt` manifest is not installed automatically.

Reason:

- we want the standard path to remain as anchored to the repos as possible
  officers;
- non-essential AUR exceptions must remain a conscious choice.

## Regola Flatpak

The `flatpaks/apps.txt` manifest is not automatically installed.

Reason:

- Flatpak is a different layer than `pacman`;
- we want to prevent it from "secretly" entering the base bootstrap.

## Deduplication rule

If the same package ends up in multiple selected manifests, the script will
install only once.

This makes manifests more forgiving without degrading execution.

## Readability rule

The installation script must:

- support `dry-run`;
- being able to show the available layers;
- being able to install only some layers;
- stay small and readable.

## Practical consequences

This choice gives us:

- an already useful initial bootstrap;
- manifests that become truly executable;
- a clear boundary between official, baseline AUR, optional AUR and Flatpak;
- a good basis for scripting from live ISO.

## For a student: the simple version

Think of manifests as a bill of materials.

The script does not have to "decide" what to install.
You just have to:

1. read the right manifestos;
2. respect the order;
3. use the correct manager;
4. Don't mix the worlds by accident.