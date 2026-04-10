# Scripts

This directory contains the project's operational scripts.

Expected categories:

- live ISO bootstrap;
- post-install;
- configuration generation;
- system validation;
- maintenance and updates.

Rule:

- keep scripts small;
- make them idempotent when possible;
- prefer readability over being "clever".
- prefer shared logic plus `--flavor` switches over long-lived divergent branches.

Operational scripts:

- `generate-limine-config`: renders `limine.conf` from the versioned template
  and the minimal machine data.
- `update-all`: canonical update orchestrator, with `dry-run` support and a
  distinction between core and optional layers.
- `deploy-boot-artifacts`: installs generated artifacts to the `ESP`, with
  preventive backups of overwritten files.
- `refresh-efi-trust`: computes the `limine.conf` hash, runs
  `limine enroll-config`, and signs the EFI chain with `sbctl`.
- `provision-secure-boot`: handles the initial `sbctl` bootstrap, firmware key
  enrollment, and optionally the first EFI trust-chain refresh.
- `provision-system-user`: creates or realigns the administrative user,
  installs the `sudoers` drop-in, and initializes user directories.
- `install-from-manifests`: installs manifest-defined layers, separating
  official repos, AUR, and Flatpak through explicit flags, with per-flavor
  manifest overrides.
- `provision-storage`: prepares disk, `LUKS2`, `Btrfs`, and subvolumes from the live ISO.
- `install-live-iso`: orchestrates `provision-storage` and `bootstrap-live-iso`
  in a single live-ISO pipeline.
- `install-live-iso-guided`: step-by-step interactive wrapper around
  `install-live-iso` and `bootstrap-live-iso`.
- `bootstrap-live-iso`: bootstrap phase 1, intended for the Arch live ISO.
- `bootstrap-in-chroot`: bootstrap phase 2, intended for the target system.
- `provision-initial-boot-chain`: closes the bootstrap by installing the
  initial `mkinitcpio + UKI + Limine` boot chain on the target system.
- `provision-boot-baseline`: installs the local boot baseline files
  (`mkinitcpio`, `vconsole`, `plymouth`, UKI splash) before regeneration.
- `stage-limine-side-by-side`: stages `Limine` as a separate EFI application,
  with config at the ESP root and a dedicated UEFI entry, without replacing the
  current bootloader.
- `validate-printing-scanning-baseline`: validates packages, services,
  discovery, printers, and scanners against the `Margine` baseline.
- `provision-virtualization-containers-baseline`: installs baseline files for
  `libvirt` and the minimal virtualization-side helpers.
- `validate-runtime-baseline`: validates power, resume, audio, network,
  Bluetooth, and screenshot/recording tooling on the real machine.
- `validate-boot-recovery-baseline`: validates the real Secure Boot, UKI,
  bootloader, and Snapper state.
- `validate-virtualization-containers-baseline`: validates CPU/KVM support,
  packages, and the real `libvirt` and `podman` state.
- `prepare-qemu-archiso-validation`: prepares a QEMU/OVMF VM with the official
  Arch ISO and a guide to validate `Margine` through a real install flow.
