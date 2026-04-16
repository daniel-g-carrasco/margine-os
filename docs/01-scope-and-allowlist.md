# Scope and initial allowlist

This file is crucial: avoid cloning your machine's junk
current.

## Basic rule

Only what is included in the project:

- wanted;
- included;
- maintainable;
- consistent with the objectives.

## Included immediately

- Minimal and playable Arch Linux
- `Hyprland` and connected components
- `waybar`
- `hyprlock`
- `hypridle`
- `hyprpaper`
- `mako`
- `walker`
- `fuzzel` as the official launcher fallback
- stack screenshot / screen recording
- `EasyEffects`
- `update-all` as operational entrypoint
- `Btrfs` + `LUKS2`
- `Secure Boot` + `TPM2`
- `greetd + tuigreet` with initial autologin and `hyprlock`
- educational documentation
- local Git repository + GitHub
- Pure `Firefox`, with enforced but not extreme configuration
- `Thunderbird` official as baseline mail client
- `kitty` as baseline terminal
- explicit tooling for coding and administration (`tmux`, `opencode`,
system monitor and CLI utilities)
- `OpenSSH` as baseline remote stack (client always present, server ready)
- pre-configured and easy to manage firewall

## Excluded immediately

- `Floorp`
- `GNOME` as the main environment
- `Ghostty` as the second baseline terminal
- blind copy of current packages
- `-git` components as the basis of the system
- AURs not strictly necessary
- `HyprPanel`

## Candidate AUR exceptions

- `koofr-desktop-bin`

Note:
- at the moment, on the current machine, `Koofr` is installed as a package
AUR (`koofr-desktop-bin`);
- it does not automatically enter the project: it must first be justified as an exception.

## Elements to be decided later

- snapshot manager (`Snapper` as base, possible compact layer)
- final choice of bootloader
- non-GNOME replacements for some current apps
- color workflow / ICC / viewer for photography
