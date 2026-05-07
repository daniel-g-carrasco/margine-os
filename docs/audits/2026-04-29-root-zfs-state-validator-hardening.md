# 2026-04-29 - Root-on-ZFS install-state and validator hardening

## Scope

This note records the hardening pass that turns the root-on-ZFS install path
from repeated local inference into an explicit state contract.

## Changes

- `provision-storage-zfs-root` now writes root-on-ZFS layout facts to both:
  - `/run/margine-install/root-zfs.env`
  - `/mnt/etc/margine/install-layout.env`
- The manifest records the storage layout, pool, root dataset, bootfs, LUKS
  mapper, LUKS UUID, ESP device, ESP UUID, ESP mountpoint, target root and ZFS
  dataset list.
- `validate-root-zfs-target` validates a mounted target in two modes:
  - `storage`: mount sources, pool health, bootfs, root dataset properties,
    `/home` and `/games` mounts when present, LUKS mapper, ESP permissions and
    fstab ZFS exclusion.
  - `boot-chain`: all storage checks plus hostid, zpool cache, mkinitcpio ZFS
    files/hooks, kernel cmdline, Limine config and UKI presence.
- `bootstrap-live-zfs-root-guided` reads the manifest when present and runs the
  storage validator before calling `bootstrap-live-iso`.
- `bootstrap-in-chroot` runs the storage validator before boot-chain
  provisioning and the boot-chain validator immediately after boot-chain
  provisioning.
- `provision-initial-boot-chain-zfs` reads the target manifest and now stops
  before UKI generation if the installed kernel package, `zfs-utils`,
  mkinitcpio preset or ZFS kernel module files are missing.
- The mount, unmount and repair helpers read the runtime manifest when present,
  reducing repeated assumptions about `rpool`, `cryptroot`, ESP and LUKS
  partitions.

## Risk

This does not prove a clean VM boot by itself. It narrows the next failure class:
if the post-LUKS panic repeats, the generated target should now fail earlier
when hostid, zpool cache, initramfs hooks, kernel/ZFS ABI, `root=ZFS=...`, ESP
mount policy or fstab policy are inconsistent.
