# 2026-04-25 - root-on-ZFS live-media gate

## Context

Goal: start the root-on-ZFS track without touching the current Btrfs installer
path.

The first gate was deliberately small:

```bash
command -v zfs
command -v zpool
modprobe zfs
zpool version
```

## Official Arch ISO result

The official Arch ISO failed the gate.

Observed in QEMU:

```text
Arch Linux 6.19.10-arch1-1
command -v zfs      -> not found
command -v zpool    -> not found
modprobe zfs        -> FATAL: Module zfs not found
zpool version       -> command not found
```

This is expected and correct: root-on-ZFS provisioning needs a loadable `zfs`
module for the running live kernel. A normal Arch ISO does not provide it.

## CachyOS ISO result

The CachyOS desktop ISO `cachyos-desktop-linux-260308.iso` passed the live ZFS
gate in QEMU.

Observed:

```text
command -v zfs      -> /usr/bin/zfs
command -v zpool    -> /usr/bin/zpool
modprobe zfs        -> success
zpool version       -> zfs-2.4.1-1, zfs-kmod-2.4.1-1
```

The first root-on-ZFS storage provisioning gate also passed:

```text
rpool ONLINE on /dev/mapper/cryptroot
bootfs: rpool/ROOT/default
rpool/ROOT/default mounted at /mnt
```

The storage gate exposed one installer-hardening issue: the ESP was initially
mounted at `/mnt/boot` with VFAT defaults equivalent to
`fmask=0022,dmask=0022`. That is too permissive for the ESP during installation,
especially because systemd boot tooling may place random-seed material there.
The provisioners now mount the ESP with `umask=0077` directly, matching the
fstab hardening already applied later by the bootstrap path.

The same screenshot also exposed a workflow issue: the storage-only ZFS
provisioner still suggested the generic `bootstrap-live-iso --target-root /mnt`
next step. That message is now replaced with an explicit storage-gate notice so
the generic Btrfs/bootstrap path is not accidentally treated as root-on-ZFS
ready.

## Decision

Do not continue root-on-ZFS validation from the official Arch ISO.

Acceptable next media:

- a CachyOS live ISO that boots a `linux-cachyos*` kernel and can install the
  matching `linux-cachyos*-zfs` package;
- a Margine custom live ISO with ZFS tools and module already present;
- a deliberately built custom Arch ISO with a matching ZFS module.

Not accepted:

- continuing through the Btrfs installer;
- attempting an ad-hoc DKMS build in RAM as the baseline path;
- creating a ZFS root pool from an environment that cannot prove module/kernel
  compatibility first.

## Changes made

Added:

- `scripts/bootstrap-live-zfs-tools`
- `scripts/provision-storage-zfs-root`
- `scripts/bootstrap-live-zfs-root-guided`
- `scripts/prepare-qemu-root-zfs-validation`

Updated:

- `scripts/prepare-qemu-archiso-validation`
  - added `--iso-structure-check arch|uefi|none`
- `scripts/prepare-qemu-root-zfs-validation`
  - defaults to `--iso-structure-check uefi`
  - points the runbook to `bootstrap-live-zfs-tools`

## Next gate

Use a CachyOS or Margine live ISO and run:

```bash
mkdir -p /root/margine-repo
mount -t 9p -o trans=virtio,version=9p2000.L margine /root/margine-repo
/root/margine-repo/scripts/bootstrap-live-zfs-tools --flavor cachyos
command -v zfs
command -v zpool
modprobe zfs
zpool version
```

If this passes, proceed to:

```bash
/root/margine-repo/scripts/provision-storage-zfs-root \
  --disk /dev/vda \
  --target-root /mnt \
  --pool-name rpool \
  --root-dataset ROOT/default \
  --yes-really-destroy-disk
```

## Current VM continuation

The current QEMU VM does not need destructive reprovisioning just for the ESP
mount option fix. Remount the already-created ESP before continuing:

```bash
sudo umount /mnt/boot
sudo mount -o umask=0077 /dev/vda1 /mnt/boot
findmnt /mnt/boot
```

Expected effective options include `fmask=0077,dmask=0077` or the equivalent
VFAT permissions derived from `umask=0077`.

After the ESP remount, use the guided root-on-ZFS bootstrap wrapper instead of
typing the full low-level `bootstrap-live-iso` command:

```bash
sudo /root/margine-repo/scripts/bootstrap-live-zfs-root-guided \
  --yes
```

The guided wrapper must ask for hostname, administrative username and real name
unless they are explicitly passed through flags or `MARGINE_INSTALL_*`
environment variables.

The wrapper repeats the required preflight checks in order:

- `/mnt` is the ZFS root dataset;
- `/mnt/boot` is mounted with restrictive VFAT permissions;
- `rpool` is online;
- `bootfs` resolves to the root dataset;
- the `cryptroot` mapper is open.

## Validation status

- Shell syntax: passed.
- Manifest/script check: passed.
- Official Arch ISO: rejected for root-on-ZFS live provisioning.
- CachyOS ZFS-capable ISO: passed live ZFS gate.
- Root-on-ZFS storage provisioning: passed initial QEMU gate.
- ESP install-time mount permissions: fixed in the provisioners.
- ZFS storage-only next-step messaging: fixed to avoid suggesting generic
  bootstrap prematurely.
- Root-on-ZFS bootstrap command length: reduced through
  `bootstrap-live-zfs-root-guided`, with automatic storage preflight.
- Root-on-ZFS bootstrap repo copy: fixed after QEMU validation exposed that
  `bootstrap-live-iso` copied repository `build/` artifacts, including qcow2
  VM disks, into the target root and exhausted storage. The repo copy now
  excludes `.git`, `build`, common build/cache directories, and VM/ISO images,
  and uses `--delete-excluded` so reruns clean previously copied artifacts.
