# 2026-04-26 - installation pipeline hardening audit

## Scope

This audit covers the live-ISO installation pipeline for both current storage
tracks:

- existing `LUKS2 + Btrfs` installation;
- experimental `LUKS2 + root-on-ZFS` installation;
- QEMU validation harnesses and generated runbooks;
- repository copy into the target system;
- destructive storage guardrails;
- boot-chain handoff between live ISO, target chroot and installed system.

## Fixes confirmed in the repos

The fixes encountered during the QEMU installation phase have been applied as
repo changes, not only as VM-local workarounds:

- live ZFS gate exists through `scripts/bootstrap-live-zfs-tools`;
- storage-only root-on-ZFS provisioning exists through
  `scripts/provision-storage-zfs-root`;
- root-on-ZFS bootstrap has a short guided wrapper,
  `scripts/bootstrap-live-zfs-root-guided`;
- the root-on-ZFS guided wrapper prompts for an administrative user password
  unless a password hash is supplied or the operator explicitly opts out with
  `--skip-user-password`;
- root-on-ZFS login recovery is available through
  `scripts/repair-zfs-root-user-login`, so a missing password or stale
  `tuigreet` cache does not require a long manual live-ISO procedure;
- ZFS-specific initial boot chain exists through
  `scripts/provision-initial-boot-chain-zfs`;
- root-on-ZFS QEMU validation guide uses the guided wrapper and lists storage
  checks before bootstrap;
- ESP is mounted with restrictive VFAT permissions during both Btrfs and ZFS
  storage provisioning;
- `bootstrap-live-iso` filters ZFS datasets from generated `fstab`;
- `bootstrap-in-chroot` skips Snapper and Timeshift for root-on-ZFS;
- repository copy excludes `.git`, `build`, common generated directories and
  VM/image artifacts;
- repository copy uses `--delete-excluded`, so reruns clean previously copied
  generated artifacts.

## Additional hardening added by this audit

The audit added stricter path guardrails:

- `bootstrap-live-iso` now rejects `--repo-dest /`;
- `install-live-iso` now rejects `--repo-dest /`;
- `bootstrap-live-zfs-root-guided` now rejects `--repo-dest /`;
- these scripts reject a repository source located under `--target-root`;
- these scripts reject a `--repo-dest` accidentally written as a host-side path
  below `--target-root`, for example `/mnt/root/margine-os`.

This closes the main class of recursive or oversized target copies discovered
when `build/qemu-*/*.qcow2` was copied into `/mnt/root/margine-os`.

## New automated validator

Added:

```bash
scripts/validate-installation-pipeline
scripts/check-bash-errexit-footguns
```

The validator is static and safe: it does not partition disks, mount filesystems
or install packages. It checks:

- executable and Bash syntax state for install/provision scripts;
- destructive operation confirmation requirements;
- refusal to use `/` as target root;
- restrictive ESP mount during installation;
- filtered and non-recursive repository copy behavior;
- root-on-ZFS package layer presence;
- ZFS root dataset, LUKS mapper and storage-layout handoff;
- ZFS-specific chroot boot provisioner selection;
- Snapper/Timeshift skip on root-on-ZFS;
- ZFS cmdline and Limine templates;
- QEMU runbook ordering and live-ZFS gate.
- root-on-ZFS guided installs cannot silently create an unusable login account;
- `tuigreet` is configured with a UID-filtered user menu and its remembered
  user cache stores the login name, not the display name.
- the ZFS login repair script can reopen the target, set the user's password,
  seed `tuigreet`, and unmount/export the pool from one live-ISO command.
- root-on-ZFS installs route `greetd` through
  `/usr/local/bin/margine-start-hyprland`, which explicitly launches Hyprland
  with the user's configured `~/.config/hypr/hyprland.conf`.
- root-on-ZFS boot-chain provisioning installs a `greetd.service` drop-in with
  `RequiresMountsFor=/home`, preventing a login session from starting against an
  unmounted home dataset.
- `bootstrap-in-chroot` now has a post-bootstrap graphical-session gate: it
  fails the install before reporting `DONE` if the user Hyprland config, Walker
  launcher, Margine Hyprland session wrapper, `greetd` wrapper command, or ZFS
  `/home` ordering are missing.
- `repair-zfs-root-desktop-session` can reopen the target from a live ISO,
  refresh the copied repo without build artifacts, reapply user desktop/runtime
  payloads, reinstall the Hyprland session launcher, and verify Walker/Hyprland
  payloads.

Run it with:

```bash
./scripts/validate-installation-pipeline
```

`check-bash-errexit-footguns` is also wired into
`check-shell-and-manifests`, and therefore into `pre-push-check`. It catches the
specific Bash failure mode found in `bootstrap-live-zfs-root-guided`: a helper
function ending with an optional `[[ ... ]] && ...` or `(( ... )) && ...`
expression. Under `set -e`, a false optional condition makes the function
return `1`, which can silently abort the caller before the real install step.

The audit fixed the same latent pattern in:

- `files/home/.local/bin/margine-import-session-environment`;
- `scripts/provision-tpm2-auto-unlock`.

Root-on-ZFS guided bootstrap also now fails early when the selected flavor does
not provide a `zfs-root-stack` package layer, instead of reaching `pacstrap`
with an empty stage-one package set.

## Root-on-ZFS Boot Panic Follow-Up

The first installed root-on-ZFS VM reached the LUKS prompt, loaded the ZFS
kernel module, then panicked with `Attempted to kill init`. This is a
boot-chain/initramfs class failure, not a desktop-session failure.

Three root causes were fixed in the install path:

- the root dataset is now created as `mountpoint=/,canmount=noauto` and is
  mounted explicitly with `mount -t zfs -o zfsutil`; this matches the ArchZFS
  initcpio hook path when ZFS datasets are intentionally filtered out of
  `/etc/fstab`;
- the previous `mountpoint=legacy` model was unsafe here because the initramfs
  hook only mounts legacy root datasets when a matching fstab entry is present;
- the ZFS initramfs configuration now preloads `zfs`, embeds `/etc/hostid` and
  `/etc/zfs/zpool.cache`, verifies the cachefile before UKI generation, removes
  `fsck` from the ZFS root hook chain, and adds `rootfstype=zfs` to the generated
  kernel command line.

The guided bootstrap now validates the root dataset properties before it starts
the chroot phase. The QEMU runbook also lists `zfs get mountpoint,canmount
rpool/ROOT/default` as a required pre-bootstrap and post-boot check.

## Live ISO AUR Boundary

The CachyOS live ISO proved too fragile as an AUR build environment: allowing an
AUR helper path to upgrade the live system can pull gigabytes of packages,
desynchronize the live package set, exhaust memory, and fail on mirror churn.

The install rule is now stricter:

- live media is only a bootstrap and storage-preparation environment;
- `install-aur-packages` refuses to run when `/` is the live ISO overlay root;
- `install-aur-packages` no longer exposes a full-system-sync option and never
  runs `pacman -Syu` internally;
- AUR builds belong in the installed target/chroot after the official package
  set is coherent, or after first boot through `update-all`;
- the next robustness improvement should be a prebuilt local package repository
  for patched packages such as Walker, so installation does not compile AUR
  packages at all.

## Prebuilt Local Package Repository

The installer now has a concrete escape hatch for patched AUR/local override
packages:

- `scripts/build-local-package-repo` builds the AUR baseline, default
  `gaming-runtime-compat` AUR layer, and requested AUR layers into
  `local-pacman-repo/` on an installed build host;
- `scripts/install-aur-packages --repo-output ...` stages built package files
  and runs `repo-add` instead of installing them into the current system;
- `scripts/install-from-manifests` checks `local-pacman-repo/` before invoking
  the AUR build path, so matching packages such as patched Walker are installed
  with `pacman -U` and do not force live ISO compilation;
- `local-pacman-repo/` is ignored by Git because it is a generated artifact, but
  it is intentionally kept inside the repo tree so the filtered installer source
  copy can carry it into the target.

This does not make AUR mandatory during installation. It makes the safe path
explicit: prebuild local packages on the host, then install them as ordinary
package files during bootstrap.

## Validation result

Executed successfully:

```bash
./scripts/validate-installation-pipeline
./scripts/check-shell-and-manifests
./scripts/check-bash-errexit-footguns
./scripts/build-local-package-repo --dry-run
git diff --check
Hyprland --verify-config
```

Result:

```text
Installation pipeline validation: OK
check-shell-and-manifests: OK
check-bash-errexit-footguns: OK
build-local-package-repo --dry-run: OK
git diff --check: OK
Hyprland config: OK
```

## Remaining validation gates

This audit validates the static install pipeline and the guardrails around the
bugs already encountered. It does not replace the end-to-end VM proof.

The remaining root-on-ZFS gates are:

- rerun the QEMU root-on-ZFS bootstrap after cleaning the partial oversized repo
  copy from the target;
- verify the chroot phase completes with the ZFS boot-chain provisioner;
- boot the installed disk through Limine;
- verify `findmnt /`, `zpool status`, `zpool get bootfs`, `/boot` permissions,
  UKIs and initramfs hooks inside the installed VM;
- run `validate-installation-pipeline`, `validate-host-health`, and
  `validate-boot-recovery-baseline` in the installed VM where applicable.
