# ADR 0009 - `update-all` Orchestration Model

## Status

Accepted

## Why this ADR exists

The project already defines:

- the boot path
- snapshot policy
- `limine.conf` generation
- the `UKI` strategy

What still needs to be explicit is how those pieces are executed during normal
system maintenance.

In other words:

- `update-all` must stay convenient
- but it must also be the canonical maintenance path of `Margine`

## Problem

A simplistic update script becomes insufficient very quickly.

For example, it may:

- update packages but forget the boot path
- update the boot path but skip `Secure Boot` validation
- update optional layers without distinguishing hard failures from soft ones

So the pipeline must be explicit.

## Decision

For `Margine v1`, `update-all` is the canonical maintenance orchestrator.

It does not replace:

- `pacman`
- `snapper`
- `snap-pac`
- AUR helpers
- `flatpak`

It coordinates them.

## Current phase order

The current phase order is:

1. create an explicit pre-update root snapshot
2. update official packages (`pacman`)
3. update AUR packages, if configured
4. update Flatpak packages, if present
5. update firmware (`fwupd`), if present
6. regenerate boot and recovery artifacts
7. run final verification and summary

## Role of each phase

### 1. Pre-update snapshot

Before mutating the system, `Margine` creates a dedicated root snapshot with
structured metadata.

This is separate from package-manager-generated snapshots and exists so the
operator always has an obvious rollback anchor tied to the maintenance run.

### 2. Pacman

This remains the most critical package phase.

Here:

- the system receives official repository updates
- `snap-pac` may still emit its own pre/post snapshots
- the most sensitive system components are updated

This phase is always a hard-failure boundary.

### 3. AUR

This is still secondary to the core operating system.

The project remains:

- official-repos first
- AUR only for explicit exceptions

So AUR is an accessory layer, not the center of the maintenance model.

### 4. Flatpak

Flatpak is not part of the boot-chain architecture.
It is handled as an optional application layer.

### 5. Firmware

Firmware is important, but lack of firmware updates must not block the normal
OS maintenance path on unsupported or inactive systems.

### 6. Boot and recovery artifacts

This is the real value-add of `Margine`.

This phase can include:

- recovery entry generation
- `limine.conf` rendering
- Limine config deployment
- `limine enroll-config`
- EFI loader refresh when needed
- Secure Boot signing and verification where applicable

### 7. Final checks

The final checks must answer a simple question:

- was the system updated
- is the boot path still coherent
- is the trust chain still healthy enough to boot predictably

## Error policy

For `v1`, errors are split into hard failures and soft failures.

### Hard failures

These must stop the orchestration.

Examples:

- failure creating the explicit pre-update snapshot
- failure in `pacman`
- failure regenerating required boot artifacts
- failure rendering or deploying `limine.conf`

### Soft failures

These should be surfaced, but do not necessarily invalidate the entire update
cycle.

Examples:

- AUR failure
- Flatpak failure
- `fwupd` unavailable or unsupported
- optional notification/reporting issues

## Runtime model

`Margine` now treats the installed runtime as part of the product:

- shared runtime logic lives under `/usr/local/lib/margine`
- `/usr/local/bin/update-all` is the canonical installed entry point
- a user-level wrapper may delegate to that runtime to avoid stale local copies

This avoids host drift where an old `$HOME/.local/bin/update-all` shadows the
real installed implementation.

## Consequences

### Positive

- the project has a single canonical maintenance path
- rollback anchors are clearer because each maintenance run creates an explicit
  snapshot
- host/runtime drift is reduced by using an installed shared runtime

### Negative

- the orchestration is more opinionated than a plain package update
- correctness depends on keeping the installed runtime and product files in sync

## Student-level summary

Explained simply:

- `update-all` is not just a nicer alias for `pacman`
- it is the place where package updates, snapshots, boot recovery, and final
  verification are coordinated

Its job is not magic.
Its job is to impose order.
