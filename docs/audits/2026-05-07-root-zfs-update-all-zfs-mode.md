# 2026-05-07 - Root-on-ZFS update-all mode audit

## Scope

This audit records the first conservative `update-all` path for installed
Margine root-on-ZFS systems.

## Problem

The previous `update-all` runtime correctly failed closed on root-on-ZFS because
the generic Btrfs/Snapper path could rewrite mkinitcpio, UKIs and Limine without
ZFS hooks, `root=ZFS=...`, `zpool.cache` and kernel/ZFS ABI validation.

In VM testing, running a stale or generic update path produced the observed boot
failure:

```text
Failed to mount /sysroot
Dependency failed for Initrd Root File System
```

## Implemented Control

`update-all` now detects a root-on-ZFS runtime and switches to a dedicated
sequence:

1. resolve pool, root dataset and LUKS mapper from `/etc/margine/install-layout.env`
   or the mounted root source;
2. run `validate-root-zfs-target --target-root / --mode boot-chain`;
3. require a healthy pool and capacity below 85%;
4. create a strict root dataset snapshot with
   `create-zfs-pre-update-snapshots --strict`;
5. clone that snapshot into a marked boot environment under `rpool/ROOT/...`;
6. regenerate the ZFS boot chain immediately so the rollback entry exists
   before package mutation starts;
7. run the standard package layers;
8. regenerate the ZFS boot chain with `provision-initial-boot-chain-zfs`,
   including Limine `/Rollback` entries for marked clones;
9. refresh EFI trust when `sbctl` is initialized;
10. rerun the root-on-ZFS validator.

The user and global `update-all` wrappers now reject stale root-on-ZFS runtimes
instead of delegating blindly.

For real root-on-ZFS updates, `--no-boot` and `--no-pre-update-snap` are refused
because they remove the two controls that prevent the known `/sysroot` boot
failure class.

## Limits

This is not yet a complete boot-environment lifecycle implementation. The
update path creates a bootable clone and a Limine entry, but clone promotion,
abandonment and pruning remain follow-up work.

## Validation Targets

Before using this on real hardware:

```bash
update-all --dry-run --no-aur --no-flatpak --no-fwupd
sudo /usr/local/lib/margine/scripts/validate-root-zfs-target --target-root / --mode boot-chain
```

After a real VM update:

```bash
sudo zfs list -t snapshot -o name,creation | grep 'rpool/ROOT/default@margine-pre-update'
sudo zfs get -r org.margine:bootenv,origin rpool/ROOT | grep margine-pre-update
sudo grep -n 'Rollback\|root=ZFS=rpool/ROOT/margine-pre-update' /boot/EFI/BOOT/limine.conf
sudo /usr/local/lib/margine/scripts/validate-root-zfs-target --target-root / --mode boot-chain
sudo sbctl verify || true
```
