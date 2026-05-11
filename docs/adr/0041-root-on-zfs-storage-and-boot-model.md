# ADR 0041 - Root-on-ZFS storage and boot model

## Status

Proposed

## Context

`Margine` currently has a working storage and recovery model based on:

- ESP mounted at `/boot`;
- `LUKS2`;
- Btrfs root;
- Snapper pre-update snapshots;
- Limine primary boot path;
- systemd-boot fallback;
- signed UKIs;
- staged Secure Boot and TPM2 rollout.

The ZFS non-root stack has already proven useful for validating OpenZFS tooling,
Sanoid policy, ZFS services and CachyOS package compatibility. It does not solve
the final target: placing the system root itself on ZFS.

Root-on-ZFS is not a small filesystem replacement. It changes:

- initramfs responsibilities;
- root import and mount semantics;
- rollback mechanics;
- kernel/module update risk;
- pre-update snapshot policy;
- bootloader entry generation;
- recovery procedure.

The design must therefore be treated as a new installation track, not an
in-place conversion of the current Btrfs layout.

## Decision

The first `Margine` root-on-ZFS prototype will use:

```text
ESP /boot
  -> signed Limine primary loader
  -> signed systemd-boot fallback loader
  -> signed primary/fallback/recovery UKIs

LUKS2 system container
  -> ZFS rpool
     -> rpool/ROOT/default mounted as /
     -> rpool/games mounted as /games
```

This means:

- keep the existing ESP + UKI + Limine + systemd-boot fallback architecture;
- keep `LUKS2` as the first encryption layer;
- keep TPM2 enrollment as a staged post-install step;
- use ZFS for the root pool and datasets;
- keep large reinstallable game libraries on a dedicated `/games` dataset;
- postpone ZFS native encryption and ZFSBootMenu to separate experiments.

## Why not start with ZFSBootMenu

ZFSBootMenu is a serious candidate for a future boot-environment model, but it
would change too many variables in the first root-on-ZFS step.

The first prototype must answer one question:

```text
Can Margine boot, update, snapshot and roll back a LUKS2-backed ZFS root while
preserving the existing Secure Boot/UKI/fallback model?
```

Only after that is true should we compare ZFSBootMenu against the Margine boot
chain.

## Partition model

Baseline single-disk laptop layout:

```text
/dev/nvme0n1p1  ESP FAT32  /boot
/dev/nvme0n1p2  LUKS2      cryptsystem
/dev/mapper/cryptsystem -> ZFS rpool
```

Rules:

- `/boot` remains outside ZFS;
- `/boot` must be mounted with restrictive FAT options such as `umask=0077`;
- no persistent swap partition by default;
- zram remains the default swap strategy;
- hibernation remains out of scope for this ADR.

## ZFS pool baseline

Initial pool name:

```text
rpool
```

Initial pool/filesystem properties:

```text
ashift=12
autotrim=on
compression=lz4
acltype=posixacl
xattr=sa
atime=off
mountpoint=none
canmount=off
```

Explicit non-goals:

- no dedup;
- no L2ARC;
- no SLOG;
- no global small recordsize;
- no high zstd level as root default;
- no automatic feature-flag upgrade without boot compatibility review.

## Dataset model

Initial datasets:

```text
rpool/ROOT/default      /
rpool/home              /home
rpool/root              /root
rpool/var/log           /var/log
rpool/var/cache         /var/cache
rpool/var/tmp           /var/tmp
rpool/data              /data
rpool/srv               /srv
rpool/containers        /var/lib/containers
rpool/machines          /var/lib/machines
rpool/vm                /var/lib/libvirt
```

The following paths remain inside the root dataset in the first baseline:

```text
/usr
/etc
/opt
/var/lib/pacman
/var/lib/systemd
```

Reason: these paths define system consistency and must roll back with the root
dataset.

## Snapshot policy

Snapper is not the primary model for root-on-ZFS.

Root snapshots:

- created explicitly before updates;
- named by Margine;
- retained conservatively;
- used to create bootable rollback candidates.

Data snapshots:

- managed periodically by Sanoid;
- dataset-specific retention;
- no attempt to make all datasets follow root rollback.

Large mutable workloads:

- VM/container datasets get conservative retention;
- no high-frequency snapshots by default.

## update-all requirements

On root-on-ZFS, `update-all` must become storage-aware.

The initial dedicated path is intentionally conservative. On an installed
root-on-ZFS runtime, `update-all` must not reuse the Btrfs/Snapper flow. It must
run a ZFS-specific sequence that validates the current boot chain, creates a
required pre-update snapshot of the root dataset, clones that snapshot into a
bootable root dataset, publishes the rollback entry before packages are touched,
updates packages, regenerates the ZFS-aware UKI/Limine chain again, refreshes
EFI trust when Secure Boot material is initialized, and validates the final boot
chain before returning.

The first rollback implementation creates bootable clone candidates under the
root boot-environment parent, for example `rpool/ROOT/margine-pre-update-*`.
Limine entries boot those clones through the cmdline-capable recovery UKI using
`root=ZFS=<clone>`. Clone promotion, clone abandonment, automatic retention
pruning and multi-dataset transactional rollback remain explicit follow-up work;
they must not be implied by merely booting a rollback candidate. Operator-driven
retention uses `prune-zfs-rollback-boot-environments`, which plans by default,
requires `--destroy` for deletion, refuses to prune from an active rollback
root, destroys clone-before-origin-snapshot, and republishes Limine after
pruning.

Rollback clones must not depend on the mutable shared recovery UKI after package
mutation. `update-all` freezes a clone-specific rollback UKI before the package
transaction and records its Limine path on the clone with
`org.margine:rollback-uki`. This prevents the Btrfs-host class of failure where
an old root is booted with a newer kernel/UKI and then loses late-loaded
hardware modules.

The rollback publication is a hard validation gate, not a best-effort log.
Before package mutation, `update-all` must run the dedicated rollback validator
against the just-created clone. The validator must prove that the clone exists,
has the expected primary-root snapshot origin, keeps `mountpoint=/` and
`canmount=noauto`, owns a frozen clone-specific UKI on the ESP, and has a Limine
entry that boots `root=ZFS=<clone>` through that frozen UKI. After a rollback
entry is selected, the same validator in active mode must prove that `/` and
`/proc/cmdline` both point at the selected clone while pool `bootfs` remains on
the primary root.

Preflight must check:

```text
zpool status -x
root dataset exists
pool capacity threshold
/boot mount and permissions
current kernel package
current ZFS module package
target kernel/ZFS module compatibility
zfs-utils availability
pre-update snapshot creation
pre-update boot-environment clone creation
published rollback boot-environment validation
post-update root-on-ZFS validator
```

Hard stop conditions:

- pool is unhealthy;
- pre-update snapshot fails;
- boot-environment clone creation fails;
- `/boot` is not mounted correctly;
- Secure Boot signing material is inconsistent;
- target kernel and ZFS module cannot be installed together;
- CachyOS flavor would move to a kernel without matching precompiled ZFS module.

The update may proceed only after the root dataset snapshot exists. If the
snapshot helper cannot create `rpool/ROOT/default@margine-pre-update-*`, package
updates must not start.

## CachyOS-specific rule

For `margine-cachyos`, root-on-ZFS depends on the CachyOS kernel/module contract:

- CachyOS provides precompiled ZFS modules for its kernel variants;
- `zfs-utils` provides userspace tooling;
- ZFS remains out-of-tree and must be treated as kernel-coupled;
- realtime kernels are not a valid root-on-ZFS baseline.

Therefore the personal flavor must not treat `linux-cachyos`, `linux-cachyos-zfs`
and `zfs-utils` as loosely related packages. They are one boot-critical unit.

## Boot and recovery requirements

The first accepted prototype must pass:

- first boot after installation;
- second boot after installation;
- update-all;
- reboot after update-all;
- signed UKI verification;
- Limine primary path;
- systemd-boot fallback path;
- recovery UKI path;
- pre-update snapshot creation;
- rollback boot environment creation;
- boot into rollback candidate;
- abandon rollback candidate;
- promote rollback candidate.

## TPM2 and Secure Boot

TPM2 remains staged.

The sequence is:

1. install root-on-ZFS without pretending TPM2 is complete;
2. validate manual LUKS unlock;
3. validate UKI and fallback boot;
4. enable Secure Boot;
5. validate Secure Boot boot path;
6. enroll TPM2 against the final stable boot state;
7. validate automatic unlock.

## Consequences

This decision creates a parallel storage track:

- current Btrfs installer remains intact;
- ZFS non-root remains useful for data-layer validation;
- root-on-ZFS gets a separate VM harness;
- boot scripts must become root-filesystem aware;
- update-all must gain ZFS preflight and rollback logic.

The cost is more implementation work.

The benefit is that a root-on-ZFS failure does not destabilize the current
installer while the new model is still being proven.

## Implementation gates

The implementation order is:

1. document this ADR;
2. create root-on-ZFS QEMU harness;
3. create `provision-storage-zfs-root`;
4. generate root-on-ZFS UKIs;
5. boot without Secure Boot;
6. boot with Secure Boot;
7. validate update-all;
8. validate rollback boot environment;
9. validate personal CachyOS/gaming flavor;
10. only then evaluate bare metal.

## References

- OpenZFS Arch Linux root-on-ZFS:
  https://openzfs.github.io/openzfs-docs/Getting%20Started/Arch%20Linux/Root%20on%20ZFS.html
- OpenZFS module parameters:
  https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Module%20Parameters.html
- OpenZFS workload tuning:
  https://openzfs.github.io/openzfs-docs/Performance%20and%20Tuning/Workload%20Tuning.html
- CachyOS filesystem guidance:
  https://wiki.cachyos.org/installation/filesystem/
- CachyOS kernel and prebuilt modules:
  https://wiki.cachyos.org/features/kernel/
- ZFSBootMenu documentation:
  https://docs.zfsbootmenu.org/
