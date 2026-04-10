# Manifests

This directory contains curated lists of components to install.

Rule:
- keep manifests small;
- use explicit names;
- do not dump `pacman -Qqe` indiscriminately.

Current state of the source machine:

- `230` explicitly installed packages;
- only part of them will actually enter `Margine`.

Approach:

- manifests must describe the target system;
- they must not snapshot the current machine;
- ambiguous cases should stay in separate notes until clarified.

Initial structure:

- `packages/base-system.txt`
- `packages/hardware-framework13-amd.txt`
- `packages/connectivity-stack.txt`
- `packages/security-and-recovery.txt`
- `packages/coding-system-tools.txt`
- `packages/virtualization-containers-stack.txt`
- `packages/hyprland-core.txt`
- `packages/toolkit-gtk-qt.txt`
- `packages/printing-scanning-stack.txt`
- `packages/desktop-integration.txt`
- `packages/apps-core.txt`
- `packages/apps-photo-audio-video.txt`
- `packages/fonts.txt`
- `packages/aur-baseline.txt`
- `packages/aur-exceptions.txt`
- `packages/open-questions.md`
- `flatpaks/apps.txt`
- `storage-subvolumes.txt`

Flavor model:

- `packages/` and `flatpaks/` are the shared baseline used by every flavor;
- `flavors/<name>/packages/*.txt` can replace individual package manifests;
- `flavors/<name>/flatpaks/apps.txt` can replace the shared Flatpak list;
- if a flavor-specific manifest does not exist, the shared baseline is used.

Current supported flavors:

- `arch`
- `cachyos`
