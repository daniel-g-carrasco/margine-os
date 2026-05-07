# 2026-04-30 - Root-on-ZFS post-install validation audit

## Status

First `margine-cachyos` personal root-on-ZFS VM boot succeeded.

Validated manually in the VM:

- Limine reached the installed boot path;
- the LUKS2 prompt appeared and unlocked the `cryptroot` mapper;
- ZFS imported and mounted the installed root;
- `greetd` appeared;
- the configured user logged into the graphical session.

This proves the previous post-LUKS `Attempted to kill init` failure is no
longer reproduced by the current boot artifacts.

## Gaps Found

The existing post-install checklist was still Btrfs/Snapper-first. On a
root-on-ZFS install that creates false signals:

- `/.snapshots` is not the root rollback model;
- Snapper root config is deliberately skipped by `bootstrap-in-chroot`;
- ZFS state must be validated through pool, dataset, bootfs and cmdline checks;
- `/games` must be checked as a dedicated dataset;
- the installed runtime validator must not silently accept
  `kernel.split_lock_mitigate=0` as the default CachyOS state.

The live-ISO detach flow also needed a readable shorthand for the final
disposable live-media recovery case. The underlying problem observed in CachyOS
was retained ZFS mounts in separate live-service mount namespaces, not direct
open files under `/mnt`.

A later recovery run exposed a second detach bug in our helper: the
`--live-iso-recovery` shorthand enabled lazy unmount before the diagnostic and
namespace cleanup passes had finished. That can detach `/mnt` from the visible
mount table while the ZFS pool remains busy, producing empty process/namespace
diagnostics followed by `cannot export 'rpool': pool is busy`.

The first attempted fix introduced a mount bug: making `/mnt` itself a private
bind mount caused `mountpoint -q /mnt` to succeed before the root ZFS dataset was
mounted. The repair helper then mounted child datasets and the ESP under a live
`airootfs` `/mnt`, so `/mnt/etc/margine/install-layout.env` was missing.

After the first successful boot, running the existing `update-all` path exposed
a boot-critical gap: Limine still showed only the fresh-install entries and the
primary entry later failed with `Failed to mount /sysroot`. The likely failure
class is the Btrfs/Snapper update path regenerating boot artifacts without the
root-on-ZFS mkinitcpio hooks, `root=ZFS=...` command line, zpool cache and
kernel/ZFS ABI checks. That path must fail closed until a dedicated ZFS update
pipeline exists.

## Integrations Added

- `unmount-zfs-root-target --live-iso-recovery` now expands to the explicit
  final live-ISO recovery path:
  `--terminate-busy --kill-busy --force-zfs-unmount --lazy-unmount --force-export`.
- `mount-zfs-root-target` makes the current live mount namespace recursively
  private before importing the pool, preventing the live desktop's service
  namespaces from inheriting target ZFS mounts without masking `/mnt`.
- `mount-zfs-root-target` now verifies that the exact source of `/mnt` is the
  root dataset and clears stale non-ZFS `/mnt` mounts such as `airootfs`.
- `unmount-zfs-root-target` delays lazy unmount until the final recovery pass so
  busy diagnostics remain visible during normal, namespace and forced-ZFS
  cleanup attempts.
- `validate-boot-recovery-baseline` detects root-on-ZFS runtimes and runs
  `validate-root-zfs-target --target-root / --mode boot-chain`.
- `validate-boot-recovery-baseline` skips Btrfs Snapper checks on root-on-ZFS.
- `validate-runtime-baseline` reports split-lock runtime and persistent state,
  and fails the baseline when the default runtime is `kernel.split_lock_mitigate=0`.
- The personal CachyOS baseline pins split-lock mitigation back to
  `kernel.split_lock_mitigate=1`; `0` remains a manual gaming override.
- `docs/05-post-install-validation.md` now includes root-on-ZFS first-boot
  checks and CachyOS split-lock checks.
- The live target mounting runbook documents the mount-namespace failure mode
  and the new `--live-iso-recovery` shorthand.
- `update-all` now detects an installed root-on-ZFS runtime and exits before
  any package, snapshot, Flatpak, firmware or boot mutation.
- `repair-zfs-root-boot-chain` provides the live-ISO recovery path for a target
  whose ZFS storage is intact but whose boot artifacts were overwritten.
- `collect-qemu-root-zfs-validation-logs` provides a host-side SSH collection
  path so post-install VM evidence is captured as text logs instead of
  screenshots.
- `enable-qemu-validation-ssh` provides the matching guest-side setup path. It
  reads the generated `qemu-margine_ed25519.pub` from the mounted QEMU build
  directory, installs it for the selected user, enables `sshd`, and starts the
  validation idle inhibitor from a temporary local guest copy. This avoids the
  previous dependency loop where SSH had to work before the inhibitor could be
  armed.
- `enable-qemu-validation-inhibit` provides the matching guest-side keep-awake
  path. It starts a validation-only systemd inhibitor for sleep and idle, and
  starts `keep-awake.service` for the logged-in user when the graphical user bus
  is available.

## Next Validation Gates

Run from the installed VM after login:

```bash
/usr/local/lib/margine/scripts/validate-host-health --session --product margine-cachyos --flavor cachyos --verbose
sudo /usr/local/lib/margine/scripts/validate-host-health --root --product margine-cachyos --flavor cachyos --skip-tpm2 --verbose
```

Then validate direct root-on-ZFS state:

```bash
findmnt /
findmnt /home
findmnt /games
findmnt /boot
sudo zpool status rpool
sudo zpool get bootfs rpool
sudo zfs get mountpoint,canmount rpool/ROOT/default
sudo cryptsetup status cryptroot
sudo /usr/local/lib/margine/scripts/validate-root-zfs-target --target-root / --mode boot-chain
```

If those pass, the next hard gates are second boot, confirmation that
`update-all` fails closed on root-on-ZFS, then implementation of the dedicated
ZFS pre-update snapshot, update, boot-regeneration and rollback
boot-environment pipeline. A real update cycle must remain blocked until that
pipeline exists.

For QEMU, first enable SSH inside the installed guest:

```bash
sudo /root/margine-repo/scripts/enable-qemu-validation-ssh --user "$USER"
```

Then collect the same evidence from the host. The inhibitor has already been
started by the guest-side SSH setup helper; the host-side inhibitor wrapper is
reserved for status, re-enable, or disable operations.

```bash
./scripts/collect-qemu-root-zfs-validation-logs --user USERNAME --prompt-sudo
```

The collector records both the user keep-awake service state and the transient
`margine-qemu-validation-inhibit.service` state. Disable the inhibitor in the
guest after evidence collection:

```bash
./scripts/enable-qemu-validation-inhibit-over-ssh --user USERNAME --disable --prompt-sudo
```
