# ADR 0010 - Boot artifact deployment model on ESP

## State

Accepted

## Why this ADR exists

So far we already have:

- generation of `limine.conf`
- orchestration of `update-all`
- `UKI` strategy

However, a fundamental principle was missing:

- how the generated artifacts actually arrive on the `ESP`

This phase is delicate.
If you design it poorly, you get a fragile boot path.

## Problem to solve

The `ESP` is a special place:

- it is out of root snapshots;
- contains boot-critical files;
- on the current machine already contains existing artifacts.

So we don't want:

- edit files directly on `ESP`;
- make opaque overwrites;
- assume that `ESP` is empty;
- introduce destructive scripts.

## Decision

For `Margine v1`, deploying to `ESP` follows this rule:

1. the artifacts are generated outside the `ESP`;
2. deployment occurs via a dedicated script;
3. existing files are backed up before overwriting;
4. in `v1` there is no aggressive automatic removal.

## Expected artifacts

The canonical targets are:

- `EFI/BOOT/BOOTX64.EFI`
- `EFI/BOOT/limine.conf`
- `EFI/Linux/margine-linux.efi`
- `EFI/Linux/margine-linux-fallback.efi`
- `EFI/Linux/margine-recovery.efi`

## Staging rule

The final file on `ESP` is not the authoritative source.

The authoritative source remains:

- the template or output generated outside the `ESP`

This implies that the deployment must copy ready-made artifacts, not build them
while writing to the boot partition.

## Regola di backup

Any target file already present and intended to be overwritten must be
copied to a backup directory before deployment.

This backup must:

- be separated from the `ESP`;
- maintain the relative structure of the paths;
- be inspectable by the user.

## Rule of prudence

In `v1`, the deployment:

- copy and update;
- does not automatically clean `ESP` of unknown files.

Reason:

- first we want a reliable deployment;
- then, if anything, more intelligent cleaning.

## Integration with update-all

`update-all` can invoke deployment if it receives:

- the path of the `ESP`
- and the paths of the necessary artifacts

This maintains a healthy separation:

- `update-all` orchestra;
- the deployment script installs on `ESP`.

## Practical consequences

This choice gives us:

- deploy readable;
- reduced risk;
- ability to understand what has been overwritten;
- good base to add after `limine enroll-config` and final signature.

## For a student: the simple version

If we explain it directly:

- you don't write by hand on the `ESP`;
- it generates outside;
- si fa backup;
- then it installs deterministically.

This is the correct way to treat a serious boot path.
