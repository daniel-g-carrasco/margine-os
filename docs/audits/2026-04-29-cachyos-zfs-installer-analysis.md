# 2026-04-29 - CachyOS ZFS installer analysis and Margine delta

## Scope

This audit analyzes the CachyOS root-on-ZFS installation path from official
documentation and source code, then compares it with the current Margine
root-on-ZFS prototype.

The goal is not to copy CachyOS blindly. The goal is to extract the reliable
installation patterns that make their ZFS path repeatable, then decide which
parts Margine should adopt, reject or adapt.

## Sources

Reviewed sources:

- CachyOS filesystem documentation:
  https://wiki.cachyos.org/installation/filesystem/
- CachyOS Calamares configuration and modules:
  https://github.com/CachyOS/cachyos-calamares
- Reviewed `cachyos-calamares` commit:
  `8b580f78804cda1bccddc095cdedeb5019fea75d`
- CachyOS settings repository, reviewed only for distro context:
  https://github.com/CachyOS/CachyOS-Settings
- Reviewed `CachyOS-Settings` commit:
  `d20a4d72150ffceccb4085fc5645c9208792e77b`

Primary CachyOS files used for this audit:

```text
cachyos-calamares/settings.conf
cachyos-calamares/src/modules/partition/partition.conf
cachyos-calamares/src/modules/zfs/zfs.conf
cachyos-calamares/src/modules/zfs/ZfsJob.cpp
cachyos-calamares/src/modules/mount/main.py
cachyos-calamares/src/modules/fstab/main.py
cachyos-calamares/src/modules/zfshostid/main.py
cachyos-calamares/src/modules/initcpiocfg/main.py
cachyos-calamares/src/modules/bootloader/main.py
```

## Executive Finding

CachyOS does not implement root-on-ZFS as a loose collection of shell commands.
It implements it as a Calamares job graph with shared installer state:

```text
partition
  -> zfs
  -> mount
  -> pacstrap
  -> fstab
  -> zfshostid
  -> initcpiocfg
  -> initcpio
  -> bootloader
  -> umount
```

That sequencing is the most important thing to learn from CachyOS.

The core pattern is:

- create ZFS pools and datasets from structured installer state;
- export the pool after creation;
- import it again with an install-time alternate root;
- mount datasets through ZFS semantics, not ad hoc manual commands;
- omit ZFS datasets from `/etc/fstab`;
- persist `/etc/hostid`;
- generate initramfs hooks from the detected storage model;
- generate bootloader command lines with `root=ZFS=<pool>/<dataset>`;
- keep bootloader-specific compatibility decisions isolated.

Margine should import those sequencing and validation ideas. Margine should not
copy CachyOS native ZFS encryption as the default, because Margine's current
boot trust model is based on `LUKS2`, signed UKIs, staged Secure Boot and staged
TPM2 enrollment.

## Official CachyOS Support Boundary

The CachyOS documentation treats Btrfs as the default filesystem and ZFS as an
advanced option.

The practical support boundary is narrow:

- the live environment must provide ZFS userspace tools;
- the live kernel must have a matching loadable ZFS module;
- the installed kernel must have a matching ZFS module package;
- CachyOS explicitly ties this path to its kernel/module packaging.

This matches what Margine already discovered during QEMU validation:

- the official Arch ISO is not a valid root-on-ZFS live environment by default;
- the CachyOS desktop ISO is valid only because it boots a CachyOS kernel and
  includes matching ZFS tooling/module support;
- a full live-ISO system upgrade is not a safe substitute for a coherent target
  package transaction.

## CachyOS Job Graph

`settings.conf` wires the ZFS path into Calamares. The important order is:

```text
partition
zfs
mount
pacstrap
...
fstab
zfshostid
initcpiocfg
initcpio
...
bootloader
...
umount
```

This order matters:

- ZFS storage is created before the generic mount module runs.
- The target is mounted before package installation.
- `fstab` is generated after storage is known.
- `zfshostid` runs before initramfs generation.
- `initcpiocfg` writes hook policy before `initcpio`.
- bootloader configuration sees the final storage model.

Margine currently approximates this through shell scripts. The reliability gap
is that shell scripts need an explicit state contract, because they do not get
Calamares `GlobalStorage` for free.

## CachyOS Partition And Bootloader Defaults

`partition.conf` sets the general storage policy:

- default filesystem: Btrfs;
- available filesystems include ZFS;
- LUKS generation: `luks2`;
- ZFS encryption can be allowed by bootloader profile;
- ESP mountpoint is `/boot` for Limine;
- Limine ESP size override is larger than the GRUB path.

For Limine, CachyOS allows ZFS encryption and uses `/boot` as the ESP mount.
For GRUB, CachyOS applies different constraints, including GRUB compatibility
handling later in the ZFS module.

Margine alignment:

- Margine already uses `/boot` as the ESP path;
- Margine already uses a larger ESP baseline for UKIs;
- Margine should keep bootloader-specific storage rules explicit;
- Margine should not allow a generic bootloader path to silently change ZFS
  pool feature compatibility.

## CachyOS Pool And Dataset Layout

The default CachyOS `zfs.conf` defines:

```text
poolName: zpcachyos
```

Pool options:

```text
-f
-o ashift=12
-o autotrim=on
-O mountpoint=none
-O acltype=posixacl
-O atime=off
-O relatime=off
-O xattr=sa
-O normalization=formD
```

Dataset options:

```text
compression=lz4
```

Default datasets:

```text
zpcachyos/ROOT                  mountpoint=none       canmount=off
zpcachyos/ROOT/cos              mountpoint=none       canmount=off
zpcachyos/ROOT/cos/root         mountpoint=/          canmount=noauto
zpcachyos/ROOT/cos/home         mountpoint=/home      canmount=on
zpcachyos/ROOT/cos/varcache     mountpoint=/var/cache canmount=on
zpcachyos/ROOT/cos/varlog       mountpoint=/var/log   canmount=on
```

This is intentionally smaller than the current Margine dataset layout.

Key technical details:

- root dataset uses `mountpoint=/` and `canmount=noauto`;
- parent datasets use `mountpoint=none` and `canmount=off`;
- `/home`, `/var/cache` and `/var/log` are split out;
- CachyOS does not create dedicated datasets for games, VM images, containers,
  `/srv`, `/root`, `/var/tmp`, or data directories in the default layout.

Margine delta:

```text
Margine:
  rpool/ROOT/default        /
  rpool/home                /home
  rpool/root                /root
  rpool/var/log             /var/log
  rpool/var/cache           /var/cache
  rpool/var/tmp             /var/tmp
  rpool/data                /data
  rpool/games               /games
  rpool/srv                 /srv
  rpool/containers          /var/lib/containers
  rpool/machines            /var/lib/machines
  rpool/vm                  /var/lib/libvirt
```

The broader Margine split is defensible for a workstation, but it raises the
number of mount and snapshot policy gates. CachyOS proves that the minimal
root-on-ZFS boot path should be validated first; extra datasets must then be
validated as policy additions, not mixed into boot debugging.

## CachyOS ZFS Creation Logic

`ZfsJob.cpp` is the core storage module.

Important behavior:

- it chooses stable device paths, preferring `/dev/disk/by-partuuid/<uuid>`;
- it waits briefly after partitioning so device nodes exist;
- it creates the pool using the configured pool options;
- when encryption is selected for the ZFS path, it uses native ZFS encryption:
  `encryption=aes-256-gcm` and `keyformat=passphrase`;
- for GRUB, it adds `compatibility=grub2`;
- it runs `zgenhostid`;
- it creates the dataset tree from `zfs.conf`;
- it records dataset metadata in Calamares shared state;
- it exports the pool after creation.

The export step is important. It forces the next stage to import the pool in a
known way. This catches a class of bugs that happen when the installer keeps
using whatever mount state happened to remain after storage creation.

Margine should adopt that concept more strongly:

```text
create pool
write install-state manifest
export pool
import pool with explicit altroot
mount datasets from manifest
validate target
bootstrap
```

## CachyOS Mount Logic

`mount/main.py` imports ZFS pools with an alternate root:

```text
zpool import -N -R <target-root> <pool>
```

If native ZFS encryption is enabled, it loads the key:

```text
zfs load-key <pool>
```

Then it mounts datasets from the dataset list recorded by the ZFS module. The
mount order is sorted by mountpoint, so parent directories are prepared before
children.

Important difference from the manual commands used during Margine debugging:

- CachyOS does not depend on the operator remembering whether a dataset has
  `mountpoint=legacy`, `canmount=noauto`, or normal ZFS mount semantics.
- The installer has structured metadata and uses it consistently.

Margine needs a comparable state contract.

Recommended Margine correction:

```text
/run/margine-install/root-zfs.env
/mnt/etc/margine/install-layout.env
```

The manifest should include at least:

```text
MARGINE_STORAGE_LAYOUT=zfs-root
MARGINE_ZFS_POOL=rpool
MARGINE_ZFS_ROOT_DATASET=rpool/ROOT/default
MARGINE_ZFS_BOOTFS=rpool/ROOT/default
MARGINE_LUKS_MAPPER=cryptroot
MARGINE_LUKS_UUID=<uuid>
MARGINE_ESP_DEVICE=<device>
MARGINE_ESP_MOUNT=/boot
MARGINE_TARGET_ROOT=/mnt
MARGINE_ZFS_DATASETS=<machine-readable list or directory file>
```

That makes recovery helpers and bootstrap scripts consume the same facts
instead of rebuilding them independently.

## CachyOS Fstab Policy

`fstab/main.py` explicitly skips ZFS partitions when generating `fstab`.

That means CachyOS expects ZFS import/mount policy to be handled by ZFS tooling
and initramfs, not by static `fstab` entries for root datasets.

Margine is aligned here in principle:

- ZFS datasets must not be written into `/etc/fstab`;
- the ESP still needs an entry;
- swap, if ever added, must be handled separately;
- Btrfs and ZFS paths must not share the same fstab generation assumptions.

The hardening rule for Margine is:

```text
validate-root-zfs-target must fail if /etc/fstab contains rpool datasets.
```

## CachyOS Hostid Handling

`zfshostid/main.py` copies `/etc/hostid` from the live environment into the
target when ZFS datasets exist.

This is not optional. A ZFS root must have stable host identity available early.

Margine already generates/persists hostid in `provision-initial-boot-chain-zfs`,
but the CachyOS model suggests a stricter gate:

```text
before UKI generation:
  /etc/hostid exists
  /etc/zfs/zpool.cache exists
  zpool cachefile points to /etc/zfs/zpool.cache
  mkinitcpio FILES includes both files
```

## CachyOS Initramfs Policy

`initcpiocfg/main.py` detects ZFS from installer state and then adjusts hooks.

Observed policy:

- for ZFS or bcachefs, the systemd hook path is disabled;
- the `zfs` hook is added;
- Plymouth is removed when ZFS encryption or classic encryption would conflict
  with the passphrase flow.

Margine currently uses:

```text
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt zfs filesystems)
```

That is closer to CachyOS than a systemd-initramfs path. This is compatible with
manual LUKS unlock first.

However, Margine has a future TPM2 auto-unlock requirement. That requirement
may push back toward systemd tooling later. It must be treated as a separate
phase:

```text
phase 1: classic encrypt + zfs + manual unlock boots reliably
phase 2: Secure Boot verifies final UKI path
phase 3: TPM2 auto-unlock is enrolled against the stable boot state
```

Do not mix these phases while the root-on-ZFS boot path is still unstable.

## CachyOS Bootloader Policy

`bootloader/main.py` derives the ZFS root from dataset metadata and emits:

```text
root=ZFS=<pool>/<root-dataset>
```

For encrypted installs it also emits either systemd-style LUKS arguments or
classic `cryptdevice=... root=/dev/mapper/...` arguments, depending on the
initramfs model.

For GRUB and ZFS, it sets:

```text
ZPOOL_VDEV_NAME_PATH=1
```

For Limine, it writes Limine configuration and tries a normal install first,
then a fallback install mode.

Margine should keep:

- `root=ZFS=rpool/ROOT/default`;
- LUKS2 outer encryption;
- Limine primary path;
- systemd-boot fallback;
- signed UKIs;
- `cryptroot` as the mapper name unless an explicit override is passed.

`cryptroot` is not a different encryption technology. It is only the device
mapper name for the opened LUKS2 container:

```text
/dev/vda2                 LUKS2 container
/dev/mapper/cryptroot     opened LUKS mapping
rpool                     ZFS pool on /dev/mapper/cryptroot
```

The naming should be documented more clearly in the installer prompts because
it has already caused operator confusion.

## Encryption Model Delta

The biggest architectural difference:

```text
CachyOS ZFS path:
  disk partition -> ZFS native encryption -> ZFS datasets

Margine target:
  disk partition -> LUKS2 -> ZFS pool -> ZFS datasets
```

Margine should not switch to native ZFS encryption by default.

Reasons:

- Margine already has a LUKS2, Secure Boot, UKI and TPM2 unlock strategy;
- Linux tooling around TPM2 auto-unlock is better integrated with LUKS2;
- native ZFS encryption changes key management and recovery semantics;
- using native ZFS encryption would make the current boot trust chain a moving
  target during a phase where boot reliability is not yet proven.

Native ZFS encryption can remain a later experiment, not the default.

## Package And Kernel ABI Delta

CachyOS documentation and packaging imply a hard kernel/module contract.

The root-on-ZFS target must treat these as one boot-critical unit:

```text
kernel package
matching ZFS kernel module package
zfs-utils
initramfs preset
UKI generation
bootloader entry
```

Margine must not let an update install a kernel without a matching ZFS module.
This is more important on a rolling system than on a fixed-release system.

Required Margine gate:

```text
for each installed/target kernel:
  matching zfs module package is installed
  modinfo -k <kernel-version> zfs succeeds in target context
  zfs-utils version is compatible with module version
  mkinitcpio preset exists
  generated UKI exists
```

The live ISO must not be upgraded to satisfy this. The package transaction must
be targeted at the installed root or a controlled package cache.

## Live ISO Boundary

The CachyOS live ISO is a valid ZFS-capable live environment, but it is not a
stable build host for Margine custom packages.

Observed failure class in Margine validation:

- AUR/local override build path pulled target dependencies into the live ISO;
- the live package set became partially upgraded;
- mirrors changed underneath the live session;
- memory pressure killed live services;
- package conflicts appeared between live and target versions.

Policy:

```text
live ISO:
  partition disks
  create/open LUKS
  create/import/mount ZFS
  pacstrap/install official target packages
  run target chroot provisioning

not live ISO:
  full system upgrade
  AUR compilation as a normal install requirement
  patched Walker build as a live dependency
```

For patched Walker and similar packages, the more repeatable path is:

- prebuild a local package repository on an installed build host; or
- build on first boot through a controlled service after the target system is
  coherent; or
- host a proper package repository.

The live installer should prefer prebuilt package artifacts and should not
compile Rust/GTK applications in a KDE live session.

## Snapshot Policy Delta

CachyOS Calamares does not define Margine's final snapshot policy. It only gets
the system installed.

Margine needs its own ZFS snapshot model:

- root snapshots before `update-all`;
- bootable rollback candidates only for coherent root states;
- Sanoid for data datasets;
- separate policy for `/games` to avoid large reinstallable libraries polluting
  system rollback;
- conservative retention for VM/container datasets.

The dedicated `/games` dataset is a good Margine addition. It should have a
snapshot policy closer to "manual or very sparse" than the root dataset. Game
libraries are usually reinstallable and can dominate snapshot size.

## Current Margine Strengths

Margine already has several good decisions:

- LUKS2 outside ZFS preserves the existing trust and TPM2 plan;
- `/boot` remains outside ZFS;
- ESP mount hardening with `umask=0077` is correct;
- root dataset uses `mountpoint=/` and `canmount=noauto`;
- `/games` is split from root and home;
- ZFS datasets are filtered out of `fstab`;
- root-on-ZFS is isolated from the current Btrfs installer path;
- validation scripts already catch many install-pipeline footguns;
- the guided wrapper now avoids a very long low-level command line.

## Current Margine Weaknesses Exposed By CachyOS

The main weakness is not the pool layout. It is state handling.

Weak areas:

- too many scripts rediscover `rpool`, `cryptroot`, target root, ESP and root
  dataset independently;
- recovery instructions previously mixed ZFS native mount semantics, legacy
  mount semantics and manual `mount -t zfs`;
- unmount/export failure handling was too easy to escalate into broad process
  killing;
- the installer path allowed AUR/local override build behavior to leak into the
  live ISO;
- the boot panic still indicates an initramfs/root handoff issue that must be
  debugged from generated target artifacts, not by adding more manual repair
  commands.

## Corrections To Import From CachyOS

### P0 - Add An Install State Manifest

Create one authoritative root-on-ZFS install-state file during storage
provisioning.

Recommended locations:

```text
/run/margine-install/root-zfs.env
/mnt/etc/margine/install-layout.env
```

Every later script should consume this instead of guessing.

### P0 - Add A Root-on-ZFS Target Validator

The validator must run before bootloader/UKI provisioning and before reporting
installation success.

Minimum checks:

```text
zpool status -x
zpool get bootfs rpool
zfs get mountpoint,canmount rpool/ROOT/default
findmnt /mnt
findmnt /mnt/home
findmnt /mnt/boot
ESP has fmask=0077,dmask=0077
/mnt/etc/hostid exists
/mnt/etc/zfs/zpool.cache exists
/mnt/etc/mkinitcpio.conf contains zfs hook
/mnt/etc/mkinitcpio.conf contains encrypt before zfs
/mnt/etc/kernel/cmdline contains root=ZFS=rpool/ROOT/default
/mnt/etc/kernel/cmdline contains the LUKS mapper path
/mnt/etc/fstab contains no rpool datasets
```

### P0 - Add Kernel/ZFS ABI Gate

Before generating UKIs:

```text
installed kernel package is known
matching ZFS module package is installed
target /usr/lib/modules/<kernel>/extramodules/zfs*.ko* exists
target zfs-utils exists
mkinitcpio preset exists
```

If this gate fails, stop. Do not attempt a live ISO full upgrade.

### P0 - Keep LUKS2 As The Default

Do not import CachyOS native ZFS encryption as the default. It solves a
different problem and conflicts with the current Margine boot trust plan.

### P1 - Use Export/Import As A Normal Gate

CachyOS exports the pool after creation and imports it again for target mount.
Margine should do the same in controlled scripts:

```text
provision storage
export pool
mount-zfs-root-target
validate target
bootstrap
```

This makes mount bugs reproducible immediately.

### P1 - Keep Mount/Unmount Helpers Conservative

The live target unmount path should remain diagnostic by default:

- never call raw `fuser -km /mnt`;
- never kill the current terminal process accidentally;
- show exact blocking processes;
- require explicit `--terminate-busy` or stronger flags.

### P1 - Keep ZFS Out Of Fstab

This is aligned with CachyOS and must remain a hard validation rule.

### P1 - Treat `/games` As A Policy Dataset

Create `/games`, but avoid root-like snapshot retention. The expected policy is:

```text
root: pre-update snapshots
home: periodic local retention
games: manual or sparse retention
vm/container datasets: conservative retention
```

### P2 - Keep Bootloader Compatibility Local

If GRUB is ever reintroduced, apply GRUB-specific ZFS compatibility in the GRUB
path only. Do not globally restrict the pool for Limine unless a Limine or UKI
boot constraint requires it.

## What Not To Import

Do not import:

- CachyOS pool name `zpcachyos`;
- CachyOS dataset names `ROOT/cos/root`;
- native ZFS encryption as the default;
- Calamares assumptions about shared global state without implementing an
  equivalent manifest;
- full live ISO upgrades;
- AUR compilation as a required live install step;
- GRUB-specific ZFS compatibility for the Limine baseline.

## Boot Panic Interpretation

The observed Margine blue-screen panic after LUKS unlock and ZFS module load is
most likely a root handoff or initramfs policy failure, not a pool creation
failure.

The panic appears after:

```text
LUKS unlock succeeds
ZFS module loads
init exits/panics
```

High-probability classes:

- generated cmdline does not match initramfs hook expectations;
- root dataset is not mounted by the initramfs despite `root=ZFS=...`;
- `hostid` or `zpool.cache` is missing from the UKI/initramfs;
- target kernel and ZFS module are mismatched;
- UKI was generated before final ZFS config files existed;
- initramfs hook order is wrong for LUKS2 outside ZFS.

Low-probability classes:

- dataset tree itself is invalid, because the pool and datasets validated in
  live environment;
- desktop session, because the panic happens before userspace login.

The next debug cycle must inspect generated target artifacts, not live shell
state:

```text
/mnt/etc/kernel/cmdline
/mnt/etc/mkinitcpio.conf
/mnt/etc/mkinitcpio.d/*.preset
/mnt/etc/hostid
/mnt/etc/zfs/zpool.cache
/mnt/boot/EFI/Linux/*.efi
/mnt/boot/limine.conf
```

## Recommended Margine Implementation Order

1. Add the install-state manifest and make all ZFS install/repair scripts read
   it.
2. Add `validate-root-zfs-target` and call it before boot provisioning.
3. Add kernel/ZFS ABI validation before UKI generation.
4. Update the root-on-ZFS QEMU runbook so the operator never types manual mount
   commands except for diagnostics.
5. Keep patched Walker out of the live install path unless a prebuilt local repo
   is present.
6. Re-run the QEMU gate from a clean disk:
   storage -> export -> mount helper -> bootstrap -> target validator -> UKI ->
   boot -> second boot.
7. Only after two clean boots, test `update-all`.
8. Only after `update-all`, test rollback snapshots.

## Bottom Line

CachyOS confirms that root-on-ZFS can be made reliable on a rolling,
performance-oriented Arch derivative, but its reliability comes from a strict
installer pipeline, not from one magic ZFS command.

For Margine the correct import is:

```text
structured state
strict storage validation
explicit import/export lifecycle
hostid/cachefile/initramfs gates
kernel/ZFS ABI gates
no live ISO upgrades
no mandatory live AUR builds
```

The incorrect import would be:

```text
native ZFS encryption by default
Calamares dataset names
manual mount recipes
bootloader-specific pool compromises
```

Margine should keep its LUKS2 + UKI + Limine + staged TPM2 strategy, but harden
the installation pipeline until it has the same deterministic state model that
CachyOS gets from Calamares.
