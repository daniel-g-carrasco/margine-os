# ADR 0003 - Layout of partitions, subvolumes and mount strategy

## State

Accepted

## Context

The current machine already has a sensible base:

- a separate `ESP` mounted on `/boot`
- rest of the disk in `LUKS2`
- root `Btrfs`
- separate subvolumes for `/`, `/home`, `/.snapshots`, `/var/cache`,
  `/var/log`

This base is good, but it's still not the best layout for the goals of
`Margine`:

- `Limine` + bootable snapshots
- `Btrfs` + `Snapper`
- very strong recovery
- future use with VMs and containers
- clean and low-noise snapshots

## Requirements

The layout must:

- remain simple to understand;
- support `LUKS2` and `Btrfs` cleanly;
- avoid bloating root snapshots unnecessarily;
- clearly distinguish between "system state" and "highly mutable data";
- be ready for `libvirt`, `systemd-nspawn` and containers;
- don't unnecessarily complicate `Limine + UKI`.

## Decision

For `Margine v1` we adopt this target layout.

## Partitions

### Partition 1

- type: `ESP`
- filesystem: `FAT32`
- size: `4 GiB`
- mountpoint: `/boot`

Reason:

- with `Limine + UKI + bootable snapshots` it is useful to have a large `/boot`;
- avoid small `ESP` reduces friction when kernel, UKI and recovery artifacts grow;
- a single `/boot` FAT is much easier to understand than a combination
`ESP + XBOOTLDR` into `v1`.

### Partition 2

- type: `LUKS2`
- size: rest of the disk
- content: a single filesystem `Btrfs`

Reason:

- a clean structure;
- linear recovery;
- no unnecessary architectural fragmentation.

## Swap

For `v1` we do NOT adopt a dedicated swap partition.

Choice:

- `zram` as main swap;
- no hibernation as required by `v1`.

Reason:

- hibernation adds important complexity to `LUKS2 + TPM2 + snapshot`;
- is not consistent with the goal of keeping the first version readable.

If hibernation becomes a real requirement in the future, it will be addressed in a separate ADR.

## Target subvolumes

### Basic subvolumes

- `@` -> `/`
- `@home` -> `/home`
- `@snapshots` -> `/.snapshots`
- `@var_log` -> `/var/log`
- `@var_cache` -> `/var/cache`
- `@var_tmp` -> `/var/tmp`
- `@root` -> `/root`
- `@srv` -> `/srv`
- `@data` -> `/data`

### Subvolumes for virtualization and containers

- `@var_lib_libvirt` -> `/var/lib/libvirt`
- `@var_lib_machines` -> `/var/lib/machines`
- `@var_lib_containers` -> `/var/lib/containers`

### Optional subvolumes, only if you really need them

- `@var_lib_docker` -> `/var/lib/docker`
- `@var_lib_flatpak` -> `/var/lib/flatpak`

## Operational reference table

| Subvolume | Mountpoint | Role | Does it enter system rollback? | Notes |
| --- | --- | --- | --- | --- |
| `@` | `/` | system status | yes | contains the actual operating system |
| `@home` | `/home` | user data | no | keeps user life separate from the rollback root |
| `@snapshots` | `/.snapshots` | Snapper storage | not directly | hosts snapshots and their metadata |
| `@var_log` | `/var/log` | persistent logs | no | avoid noise in root snapshots |
| `@var_cache` | `/var/cache` | persistent caches | no | avoid unnecessary snapshot growth |
| `@var_tmp` | `/var/tmp` | temporary persistent | no | separates ephemeral but persistent files on reboots |
| `@root` | `/root` | administrative operating space | no | avoid mixing admin and OS status material |
| `@srv` | `/srv` | data served locally | no | useful for local services and publish trees |
| `@data` | `/data` | datasets, archives, staging | no | neat stitch for large or long-lived material |
| `@var_lib_libvirt` | `/var/lib/libvirt` | rootful virtualization | no | contains images, XML and libvirt runtime |
| `@var_lib_machines` | `/var/lib/machines` | `systemd-nspawn` | no | separate nspawn machines/images from OS snapshots |
| `@var_lib_containers` | `/var/lib/containers` | rootful containers | no | covers rootful Podman and similar workloads |
| `@var_lib_docker` | `/var/lib/docker` | Rootful Docker | no | is created only if Docker actually enters the project |
| `@var_lib_flatpak` | `/var/lib/flatpak` | System Flatpak | no | optional: only useful if Flatpak system-wide will be part of the allowlist |

## Data policy for modern workloads

### VM

For VMs we want to separate two categories:

- hypervisor metadata and runtime;
- actual disk images.

`/var/lib/libvirt` is then separated as a dedicated subvolume.
If we will use very large or high writing images, we will be able to apply
`NOCOW` targeted only to directories such as:

- `/var/lib/libvirt/images`
- `/data/vm`

### Container

For containers we must distinguish between `rootful` and `rootless`.

- `rootful` typically uses `/var/lib/containers`
- `rootless` typically uses `~/.local/share/containers`

This means that the proposed layout already covers the `rootful` containers well,
while those `rootless` naturally remain inside `@home`, that is, outside the
system rollback but inside user data.

### Flatpak

We do not assume that `Flatpak` is part of `v1`.
If it enters, we will distinguish:

- `system-wide`: candidate for `@var_lib_flatpak`
- `per-user`: it will remain under `~/.local/share/flatpak`, then inside `@home`

## Important architectural rule

Root snapshots must contain system state.

They must not contain, as far as possible:

- cache;
- high rotation log;
- persistent temporary files;
- VM disks;
- container storage;
- voluminous and highly mutable user datasets.

This is the real reason for the layout.
It is not "aesthetic order". It is rollback quality.

## What remains inside the root snapshot

Everything that defines the system remains inside `@`:

- `/etc`
- `/usr`
- `/opt`
- `/var/lib/pacman`
- `/var/lib/systemd`
- system configurations that need to go back with the system

## What we DO NOT separate

### `/opt`

Remains inside `@`.

Reason:

- many packages install there;
- separating it would increase the risk of misalignment between database and package
real content.

### `/var/lib/pacman`

Remains inside `@`.

Reason:

- the database package must remain consistent with the system snapshot;
- separating it would make rollbacks much more ambiguous.

## Mount options

### Btrfs

For Btrfs subvolumes we will use as a basis:

- `rw`
- `relatime`
- `compress=zstd:3`
- `ssd`

Conscious choices:

- we don't aim for aggressive or "benchmark" mount options;
- we want a stable and readable system;
- `zstd` compression is a real advantage on modern laptops.

However, we will not set in `fstab`, unless really necessary:

- `space_cache=v2`
- `autodefrag`
- `discard=async`

Reason:

- we prefer to explain only what is truly an architectural choice;
- we leave to the modern defaults of the Btrfs kernel what we don't need to harden.

### Trim

Usiamo:

- `fstrim.timer`

We do not use as default:

- `discard=async`

Reason:

- we prefer a more linear and less noisy strategy from the point of view of
  mount.

## NOCOW

We will not use `NOCOW` indiscriminately.

We'll only apply it where it really makes sense, and before the data is written:

- `/var/lib/libvirt/images`
- any user directories dedicated to disk images, for example
  `/data/vm`

We will not apply it by default to:

- `/var/lib/containers`

Reason:

- containers have different patterns from VM disk images;
- a blanket `NOCOW` here would be too crude a choice.

## Recovery philosophy

System recovery will follow this logic:

- root snapshots are used to recover the system state;
- `home`, `data`, VMs and containers must not pollute that snapshot;
- `Limine` must be able to expose bootable snapshots in a clear way;
- the restore must be understandable even with a cold mind.

## Relationship to the current layout

### What we keep

- `ESP + LUKS2 + Btrfs`
- `@`
- `@home`
- `@snapshots`
- `@var_log`
- `@var_cache`

### What we improve

- we add `@var_tmp`
- we add `@root`
- we add `@srv`
- we add `@data`
- we separate the virtualization and container areas
- we define an explicit strategy `NOCOW`
- let's set mount options that make more sense for the new architecture

## Because this is the best layout for Margin

Because it balances four things well together:

1. strong recovery;
2. mental simplicity;
3. compatibility with `Btrfs + Snapper`;
4. future growth towards VMs and containers without dirtying the root snapshots.

It's not the "minimalest possible" layout.
It is the layout most consistent with the project.

## References

- ArchWiki, `Btrfs`:
  https://wiki.archlinux.org/title/Btrfs
- ArchWiki, `Snapper`:
  https://wiki.archlinux.org/title/Snapper
- ArchWiki, notes on Btrfs layouts and snapshots:
  https://wiki.archlinux.org/title/User:M0p/Btrfs_subvolumes
- ArchWiki, example layout with separate subvolumes:
  https://wiki.archlinux.org/title/User:Thawn