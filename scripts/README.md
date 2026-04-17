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
- prefer shared logic plus product-aware metadata over long-lived divergent branches.

## Product model

Operational scripts now distinguish between:

- `--product`: the deliverable being built or maintained;
- `--flavor`: the manifest overlay used to resolve package layers.

In normal usage, `--product` should be preferred. `--flavor` remains available
as an escape hatch and compatibility layer.

Operational scripts:

- `generate-limine-config`: renders `limine.conf` from the versioned template
  and the minimal machine data.
- `update-all`: canonical update orchestrator, with `dry-run` support and a
  distinction between core and optional layers. On installed systems it now
  also keeps the active Limine trust chain aligned by reinstalling the unsigned
  loader, reenrolling `limine.conf`, and re-signing the loader before final
  verification. When `memtest86+-efi` is installed, it also re-signs the
  `Memtest86+` EFI binary so the diagnostics entry keeps working under Secure
  Boot.
- `deploy-boot-artifacts`: installs generated artifacts to the `ESP`, with
  preventive backups of overwritten files.
- `refresh-efi-trust`: computes the `limine.conf` hash, runs
  `limine enroll-config`, and signs the EFI chain with `sbctl`. It first
  reinstalls the unsigned Limine EFI binary on every detected Limine target
  path so the trust refresh starts from a clean loader state and duplicate
  Limine copies cannot silently diverge. When present, it also signs the
  `Memtest86+` EFI payload installed on the ESP.
- `provision-secure-boot-preflight`: exports the currently enrolled public
  Secure Boot keys, lists EFI binaries on the ESP, and prepares the operator
  for the firmware-side Setup Mode step.
- `provision-secure-boot`: handles the initial `sbctl` bootstrap, firmware key
  enrollment, requires the preflight stamp by default, and optionally performs
  the first EFI trust-chain refresh.
- `provision-tpm2-auto-unlock`: stages and then enrolls TPM2-backed LUKS
  auto-unlock in a safe two-step flow built around `systemd-cryptenroll`.
- `provision-system-user`: creates or realigns the administrative user,
  installs the `sudoers` drop-in, and initializes user directories.
- `install-from-manifests`: installs manifest-defined layers, separating
  official repos, AUR, and Flatpak through explicit flags, with per-flavor
  manifest overrides.
- `create-zfs-pre-update-snapshots`: optional helper for explicit pre-update
  snapshots of configured non-root `ZFS` datasets. It is intentionally kept
  separate from the current `Snapper` root flow until the `ZFS` non-root layer
  is validated in practice.
- `provision-zfs-non-root-baseline`: installs the versioned `sanoid` config,
  the configured dataset list for pre-update snapshots, and the local systemd
  units for the optional `ZFS` non-root experiment. This is still separate from
  any `root-on-ZFS` path.
- `provision-storage`: prepares disk, `LUKS2`, `Btrfs`, and subvolumes from the live ISO.
- `install-live-iso`: orchestrates `provision-storage` and `bootstrap-live-iso`
  in a single live-ISO pipeline. It now also accepts repeatable
  `--extra-layer` flags so exploratory layers can be installed during the same
  bootstrap instead of being added manually later.
- `install-live-iso-guided`: step-by-step interactive wrapper around
  `install-live-iso` and `bootstrap-live-iso`, including the same optional
  `--extra-layer` pass-through.
- `bootstrap-live-iso`: bootstrap phase 1, intended for the Arch live ISO. It
  forwards optional `--extra-layer` requests to the chroot phase. For flavors
  such as `cachyos`, it must first bootstrap the flavor repositories in the
  live environment before the first `pacstrap`, otherwise the stage-1 package
  set cannot resolve flavor-specific packages. It also validates repeatable
  `--extra-layer` names up front, so a typo fails immediately instead of only
  after the stage-1 install has already spent time on `pacstrap`.
- `bootstrap-in-chroot`: bootstrap phase 2, intended for the target system.
  It can install extra manifest layers requested from the live-ISO side and now
  auto-runs the `ZFS` non-root provisioner when `zfs-non-root-stack` is part of
  the selected layer set. For flavors such as `cachyos`, it also bootstraps the
  flavor repositories inside the target root before the phase-2 manifest
  install.
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
- `validate-tpm2-auto-unlock`: inspects the current TPM2/LUKS enrollment,
  `crypttab.initramfs`, `sbctl`, and PCR state. It also makes the `PCR 7` to
  `Secure Boot` dependency explicit, so a manual `LUKS` password prompt after
  disabling Secure Boot is reported as an expected policy consequence rather
  than as an ambiguous TPM2 failure.
- `validate-host-health`: single entrypoint for installed-system validation;
  run it once in the graphical user session and once as root to cover runtime,
  boot, recovery, and TPM2 checks in a consistent way. It autodetects the
  installed `product/flavor` context, accepts `--product` and `--flavor`
  overrides, prints a concise `PASS / WARN / FAIL` report by default, supports
  `--verbose` for full underlying validator output, and returns non-zero when
  it finds real baseline drift instead of just printing informational output.
- `validate-virtualization-containers-baseline`: validates CPU/KVM support,
  packages, and the real `libvirt` and `podman` state.
- `prepare-qemu-archiso-validation`: prepares a QEMU/OVMF VM with the official
  Arch ISO and a guide to validate `Margine` through a real install flow, with
  optional vTPM wiring when `swtpm` is available on the host. It now also
  supports repeatable `--extra-layer` flags and, when `zfs-non-root-stack` is
  requested, automatically attaches a second qcow2 disk for the non-root ZFS
  lab inside the guest. It emits both a live-ISO guide and a second
  installed-system checklist so the full `CachyOS + ZFS non-root + gaming`
  guest can be validated with a repeatable runbook instead of ad-hoc notes.
  Before launching QEMU it now also inspects the ISO contents directly and
  fails fast on truncated/corrupt images instead of silently dropping into an
  unbootable UEFI PXE path.
- `provision-host-root-baseline`: reapplies the root-owned host baseline for
  fingerprint auth, Framework power/lid policy, Snapper recovery, and Limine
  recovery entries on an already-installed machine.
- `provision-host-greetd-baseline`: switches an already-installed host from
  `gdm` to `greetd + tuigreet`, reapplies fingerprint PAM baseline (including
  `greetd` and `hyprlock`), and keeps rollback commands explicit.
- `provision-gaming-split-lock`: optional operator-controlled toggle for the
  `kernel.split_lock_mitigate` gaming tweak; it is intentionally separate from
  the gaming package layers so the performance/security tradeoff remains
  explicit.
