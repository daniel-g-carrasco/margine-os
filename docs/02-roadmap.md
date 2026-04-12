# Roadmap

## Phase 0 - Method

Objective:
- establish structure, naming, principles, documentation and rules of the game.

Deliverable:
- repo initialized;
- vision;
- roadmap;
- initial ADRs;
- initial allowlist.

## Phase 1 - Architecture

Objective:
- decide the foundations that influence everything else.

Topics:
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

## Phase 3 - Manifests

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

## Phase 4 - Bootstrap

Objective:
- write installation scripts from live ISO.

Topics:
- partitioning;
- encryption;
- subvolumes;
- `pacstrap`;
- chroot;
- boot;
- user;
- baseline services.

## Phase 5 - Desktop layer

Objective:
- make the system usable, coherent and centralized.

Topics:
- Hyprland configuration;
- `greetd + tuigreet`;
- Omarchy-style centralized theme;
- waybar;
- hyprpaper;
- hyprlock;
- mako;
- walker;
- screenshots and recording;
- audio, Bluetooth, networking.

## Phase 6 - Operations and rollback

Objective:
- create a system that updates and recovers well.

Topics:
- `update-all`;
- pre/post snapshots;
- kernel/UKI signing;
- preflight `Secure Boot`;
- guided `sbctl` bootstrap;
- two-phase `TPM2` rollout;
- verify integrity;
- rollback procedures;
- maintenance documentation.

## Phase 7 - Photo profile

Objective:
- close the circle for photographic use.

Topics:
- stable AMD stack;
- acceleration;
- color management;
- ABM / power tuning;
- photo applications;
- file management and ingest.
