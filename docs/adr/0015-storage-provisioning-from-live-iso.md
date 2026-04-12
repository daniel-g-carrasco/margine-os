# ADR 0015 - Provisioning storage from live ISO

## State

Accepted

## Why this ADR exists

With ADR 0014 we have separated:

- ISO live phase
- fase chroot

However, the previous step was missing:

- really prepare the target storage.

## Problem to solve

To install `Margine` from scratch, very delicate operations are required:

- create the GPT table;
- create the `ESP`;
- prepare `LUKS2`;
- create the `Btrfs` filesystem;
- create subvolumes;
- mount the target layout in a manner consistent with the project.

If this step remains manual or implicit, the bootstrap remains incomplete.

## Decision

For `Margine v1`, storage provisioning will be handled by a separate script
to be performed from the live ISO.

The script must:

1. operate on an explicitly indicated disk;
2. require explicit destructive confirmation;
3. create `GPT + ESP + LUKS2 + Btrfs`;
4. create the subvolumes by reading the project manifest;
5. Mount the target ready to bootstrap live ISO.

## Destructiveness rule

The script is destructive by design.

For this reason, in `Margine v1`, it never starts without an explicit confirmation flag.

The following are not allowed:

- disk autodetect;
- "best guess" on the correct target;
- silent execution on unconsignaturesd devices.

## Adjust partitions

The scheme adopted is the one already decided by ADR 0003:

- partition 1: `ESP` FAT32 from `4 GiB`
- partition 2: rest of the disk in `LUKS2`

## Adjust filesystem

Inside `LUKS2` you create a single filesystem `Btrfs`.

Subvolumes are created by reading `manifests/storage-subvolumes.txt`.

This prevents the script and the architectural document from diverging.

## Mount rule

The final target is mounted like this:

- `@` to `/`
- other subvolumes on their respective mountpoints
- `ESP` to `/boot`

The basic mount options are consistent with ADR 0003:

- `rw`
- `relatime`
- `compress=zstd:3`
- `ssd`

## Scope rule

In `Margine v1`, this script does not yet do:

- enrollment `TPM2`
- installing the bootloader
- final configuration of `crypttab`
- advanced or multi-disk partitioning
- hibernation

It does only one thing:

- prepare the disk well for the next bootstrap.

## Practical consequences

This choice gives us:

- a repeatable storage path;
- consistency between ADR, manifest and script;
- less risk of manual errors;
- a strong base for complete installation.

## For a student: the simple version

Pensa così:

- first prepare the ground;
- then build the house.

Storage provisioning is where you set the stage.