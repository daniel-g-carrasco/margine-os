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
  Boot. On root-on-ZFS it uses a dedicated conservative path: validate the
  current ZFS boot chain, create a required root dataset snapshot, clone that
  snapshot into a bootable root dataset, publish the rollback Limine entry
  before package mutation, run the package layers, regenerate the ZFS UKI/Limine
  chain again with rollback entries, refresh EFI trust when `sbctl` is
  initialized, and validate the result before returning.
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
  manifest overrides. When `local-pacman-repo/` contains prebuilt packages, it
  installs those first instead of building matching AUR packages in the current
  environment.
- `build-local-package-repo`: build-host helper that turns the AUR baseline,
  default gaming runtime compatibility AUR layer, and requested AUR layers into
  a local pacman repository under `local-pacman-repo/`. This is the preferred
  path for patched packages such as Walker: build them on an installed system,
  copy the generated local repo with the installer source, and keep the live ISO
  out of AUR compilation and full-system upgrades.
- `create-zfs-pre-update-snapshots`: helper for explicit pre-update snapshots
  of configured non-root `ZFS` datasets and for the root dataset snapshot used
  by root-on-ZFS `update-all`. Its strict mode fails hard when a required
  dataset is missing so package updates cannot proceed without a rollback
  anchor.
- `create-zfs-boot-environment`: turns a root dataset snapshot into a sibling
  `rpool/ROOT/...` clone marked with Margine ZFS user properties. These clones
  are bootable rollback candidates and are not promoted automatically.
- `generate-zfs-boot-environment-entries`: renders Limine rollback entries for
  marked root-on-ZFS clones. Entries use the cmdline-capable recovery UKI and
  boot with `root=ZFS=<clone>`.
- `provision-zfs-non-root-baseline`: installs the versioned `sanoid` config,
  the configured dataset list for pre-update snapshots, and the local systemd
  units for the optional `ZFS` non-root experiment. This is still separate from
  any `root-on-ZFS` path.
- `bootstrap-live-zfs-tools`: validates or bootstraps `zfs`, `zpool`, and a
  loadable `zfs` module inside the live ISO before root-on-ZFS storage
  provisioning. It only supports live kernels with a prebuilt matching ZFS
  module package, currently the `linux-cachyos*` family. On the official Arch
  ISO it fails explicitly and points to a ZFS-capable installer medium instead
  of attempting a fragile DKMS build in RAM.
- `provision-storage`: prepares disk, `LUKS2`, `Btrfs`, and subvolumes from the live ISO.
- `provision-storage-zfs-root`: prepares the experimental root-on-ZFS storage
  layout from the live ISO. It is intentionally storage-only: it creates the
  ESP, `LUKS2`, `rpool`, root dataset, desktop datasets and mount layout, but
  does not pretend that the boot chain is root-on-ZFS-ready yet.
- `bootstrap-live-zfs-root-guided`: short root-on-ZFS bootstrap wrapper for an
  already prepared target. It validates `/mnt`, `/mnt/boot`, restrictive ESP
  permissions, `rpool` bootfs, the root dataset, and the LUKS mapper, then calls
  `bootstrap-live-iso` with the correct `--storage-layout zfs-root` arguments.
- `mount-zfs-root-target` / `unmount-zfs-root-target`: canonical live-ISO
  helpers for mounting and detaching an installed root-on-ZFS target. The mount
  helper makes the current live mount namespace private before importing ZFS so
  desktop live services do not inherit target mounts through mount propagation,
  and it verifies that `/mnt` is actually the root ZFS dataset. The unmount
  helper diagnoses direct file references and retained mount namespaces, and
  keeps lazy unmount as the final explicit live-ISO recovery step.
- `collect-qemu-root-zfs-validation-logs`: host-side SSH collector for an
  installed QEMU root-on-ZFS guest. It writes separate user/root validation logs
  under `build/qemu-root-zfs-validation-logs/`, captures an `update-all`
  root-on-ZFS dry-run, records the QEMU validation idle inhibitors,
  and supports `--prompt-sudo` when the guest requires an interactive sudo
  password. With `--prompt-sudo`, the sudo prompt remains visible in the host
  terminal while root output is also saved to the log file.
- `apply-qemu-root-zfs-update-runtime-over-ssh`: host-side repair helper for an
  installed QEMU root-on-ZFS guest that needs the current repository copy of the
  installed `update-all` runtime. It uploads a filtered repository snapshot over
  SSH into guest-local `/var/tmp`, refreshes the global updater, reinstalls the
  user wrapper, and writes `~/update-all-zfs-rollback-dryrun.log`. This path
  avoids guest-side 9p mounts because a stuck kernel 9p mount can become
  unkillable during validation.
- `apply-qemu-branding-assets-over-ssh`: host-side helper for pushing the
  current Margine logo/Plymouth/fastfetch assets into an installed QEMU guest.
  It uploads a filtered repository snapshot over SSH, applies
  `provision-branding-assets`, and refreshes either the root-on-ZFS boot chain
  or the generic `mkinitcpio` path according to the guest install manifest.
- `enable-qemu-validation-ssh`: guest-side helper that installs the generated
  QEMU validation public key from `build/qemu-root-zfs-*/qemu-margine_ed25519.pub`
  into the selected user's `authorized_keys`, enables the SSH server, and
  starts the validation idle inhibitor from a temporary local guest copy. Use it
  from the mounted 9p repository instead of copying a long public key by hand.
- `enable-qemu-validation-inhibit`: guest-side helper for installed QEMU
  validation runs. It starts `margine-qemu-validation-inhibit.service` as either
  the installed persistent validation unit or a transient systemd inhibitor for
  sleep and idle, and starts the user's `keep-awake.service` when a graphical
  user bus is available. Disable it with `--disable` after collecting logs.
- `enable-qemu-validation-inhibit-over-ssh`: host-side wrapper that uploads
  `enable-qemu-validation-inhibit` to `/tmp` in the installed QEMU guest, repairs
  the persistent `margine-qemu-validation-inhibit.service` unit in enable mode,
  and runs the helper from the guest's local filesystem. Use this for
  post-install VM validation instead of executing the inhibitor directly from
  the 9p repository mount.
- `repair-zfs-root-boot-chain`: live-ISO helper for a root-on-ZFS target whose
  storage is intact but whose boot artifacts are suspect. It mounts the target,
  refreshes `/root/margine-os`, reruns `provision-initial-boot-chain-zfs` in
  chroot, validates `validate-root-zfs-target --target-root / --mode boot-chain`,
  and can detach through `unmount-zfs-root-target --live-iso-recovery`.
- `install-live-iso`: orchestrates `provision-storage` and `bootstrap-live-iso`
  in a single live-ISO pipeline. It now also accepts repeatable
  `--extra-layer` flags so exploratory layers can be installed during the same
  bootstrap instead of being added manually later.
- `install-live-iso-guided`: step-by-step interactive wrapper around
  `install-live-iso` and `bootstrap-live-iso`, including the same optional
  `--extra-layer` pass-through.
- `bootstrap-live-iso`: bootstrap phase 1, intended for the Arch live ISO. It
  forwards optional `--extra-layer` requests to the chroot phase. For flavors
  such as `arch` and `cachyos`, it must first bootstrap the flavor repository
  policy in the live environment before the first `pacstrap`; for `arch` this
  currently means ensuring `multilib`, while `cachyos` also needs the external
  keyring and mirrorlists. Stage 1 intentionally stays
  minimal and currently installs only `base-system`; hardware, security, and
  hook-heavy layers are deferred to phase 2 so `pacstrap` cannot leave stale
  package state behind or trigger misleading snapshot-hook errors during the
  bootstrap context. It also validates repeatable `--extra-layer` names up
  front, so a typo fails immediately instead of only after the stage-1 install
  has already spent time on `pacstrap`.
- `bootstrap-in-chroot`: bootstrap phase 2, intended for the target system.
  It can install extra manifest layers requested from the live-ISO side and now
  auto-runs the `ZFS` non-root provisioner when `zfs-non-root-stack` is part of
  the selected layer set. For flavors such as `cachyos`, it also bootstraps the
  flavor repositories inside the target root before the phase-2 manifest
  install.
- `provision-initial-boot-chain`: closes the bootstrap by installing the
  initial `mkinitcpio + UKI + Limine` boot chain on the target system.
- `provision-boot-baseline`: installs the local boot baseline files
  (`mkinitcpio`, `vconsole`, `plymouth`, UKI splash and Margine branding
  assets) before regeneration.
- `provision-branding-assets`: installs the Margine system logo set
  (`/usr/share/margine/branding`, Plymouth watermark, UKI splash bitmap,
  hicolor/pixmaps icons) and, when given `--username`, the user `fastfetch`
  ASCII-logo wrapper.
- `stage-limine-side-by-side`: stages `Limine` as a separate EFI application,
  with config at the ESP root and a dedicated UEFI entry, without replacing the
  current bootloader.
- `validate-printing-scanning-baseline`: validates packages, services,
  discovery, printers, and scanners against the `Margine` baseline.
- `provision-virtualization-containers-baseline`: installs baseline files for
  `libvirt` and the minimal virtualization-side helpers.
- `validate-runtime-baseline`: validates power, resume, audio, network,
  Bluetooth, launcher/runtime state, split-lock policy, and
  screenshot/recording tooling on the real machine.
- `validate-boot-recovery-baseline`: validates the real Secure Boot, UKI,
  bootloader, and storage-specific recovery state. On root-on-ZFS it runs the
  root-ZFS validator against `/` and skips Btrfs Snapper assumptions.
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
- `validate-installation-pipeline`: static installation pipeline guard for the
  Btrfs and root-on-ZFS installers. It checks executable/syntax state,
  destructive-operation confirmations, target/repo path safety, filtered repo
  copy behavior, restrictive ESP mount handling, root-on-ZFS package/boot-chain
  coupling, and QEMU runbook gates.
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
- `prepare-qemu-root-zfs-validation`: prepares the separate root-on-ZFS QEMU
  harness. It reuses the stable Arch ISO harness for OVMF, vTPM, SSH helpers
  and launchers, then replaces the in-guest runbooks with root-on-ZFS gates.
  This keeps the Btrfs installer path untouched while the new storage/boot
  model is still experimental.
- `provision-arch-repositories`: keeps the Arch flavor simple but still
  bootstrap-aware by ensuring that `multilib` is active before the default
  gaming runtime layer or optional launcher layers are installed in either the
  live-ISO or chroot phase.
- `provision-host-root-baseline`: reapplies the root-owned host baseline for
  fingerprint auth, Framework power/lid policy, Snapper recovery, and Limine
  recovery entries on an already-installed machine.
- `provision-host-greetd-baseline`: switches an already-installed host from
  `gdm` to `greetd + tuigreet`, reapplies fingerprint PAM baseline (including
  `greetd` and `hyprlock`), and keeps rollback commands explicit.
- `provision-gaming-split-lock`: optional operator-controlled toggle for the
  `kernel.split_lock_mitigate` gaming tweak; it is intentionally separate from
  the gaming package layers so the performance/security tradeoff remains
  explicit. The default baseline is mitigation active (`1`); `0` is a manual
  gaming override.
