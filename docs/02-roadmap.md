# Roadmap

## Fase 0 - Metodo

Objective:
- establish structure, naming, principles, documentation and rules of the game.

Deliverable:
- repo initialized;
- vision;
- roadmap;
- Initial ADR;
- initial allowlist.

## Fase 1 - Architettura

Objective:
- decide the foundations that influence everything else.

Temi:
- bootloader;
- Secure Boot;
- TPM2;
- LUKS2;
- layout Btrfs;
- snapshot/rollback strategy;
- session manager;
- policy AUR.

## Phase 2 - Guided inventory

Objective:
- understand the current system without blindly copying it.

Output:
- list of packages to keep;
- list of packages to discard;
- list of services to replicate;
- list of configurations to rewrite;
- list of components to replace.

## Fase 3 - Manifests

Objective:
- create small, readable manifests.

Examples:
- `base`
- `hardware-framework13-amd`
- `connectivity-stack`
- `security`
- `hyprland-core`
- `desktop-tools`
- `photo`
- `aur-exceptions`

## Fase 4 - Bootstrap

Objective:
- write installation scripts from live ISO.

Temi:
- partitioning;
- encryption;
- subvolumes;
- `pacstrap`;
- chroot;
- boot;
- user;
- servizi base.

## Fase 5 - Desktop layer

Objective:
- make the system usable, coherent and centralized.

Temi:
- config Hyprland;
- `greetd + tuigreet`;
- Omarchy-style centralized theme;
- waybar;
- hyprpaper;
- hyprlock;
- mako;
- walker;
- screenshot e recording;
- audio, bluetooth, rete.

## Phase 6 - Operations and rollback

Objective:
- create a system that updates and recovers well.

Temi:
- `update-all`;
- pre/post snapshots;
- firma kernel/UKI;
- preflight `Secure Boot`;
- bootstrap `sbctl` guidato;
- two-phase `TPM2` rollout;
- verify integrity;
- rollback procedures;
- maintenance documentation.

## Fase 7 - Photo profile

Objective:
- close the circle for photographic use.

Temi:
- stable AMD stack;
- acceleration;
- color management;
- ABM / power tuning;
- photo applications;
- file management e ingest.
