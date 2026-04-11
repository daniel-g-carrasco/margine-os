# ADR 0025 - Limine Recovery Entries Generated From Snapper Snapshots

## Status

Accepted

## Context

The project already had:

- `Snapper`
- `Limine`
- separate `UKI` images for primary, fallback, and recovery
- a versioned `limine.conf` template

The missing piece was:

- turning `Snapper` snapshots into real bootable entries in the menu

## Decision

`Margine v1` automatically generates `Limine` entries from the root `Snapper`
config snapshots.

Snapshot entries:

- point to the shared recovery `UKI`
- boot the selected Btrfs snapshot with `rootflags=subvol=...`
- use `systemd.unit=graphical.target`
- boot in `ro`, not `rw`

`Manual recovery` remains a separate lower-level entry.

## Rationale

### Why the recovery UKI is used

For snapshot boot, the first priority is:

- inspection
- fast recovery access
- deliberate rollback decisions

The recovery `UKI` is a better fit than the primary `UKI` for that workflow.

### Why snapshots boot read-only

A standard `Snapper` snapshot should be treated as a safe reference point.

Booting it read-only reduces the risk of:

- accidentally turning it into a mutable environment
- confusing "inspection" with "permanent rollback already done"

### Why snapshot entries use `graphical.target`

The project originally used `multi-user.target` for snapshot entries.

That was safe, but it forced users into a TTY even when the goal was simply to
inspect an older working desktop state.

The current model keeps snapshot boots read-only while allowing the graphical
session to start.

## Important rule

A bootable snapshot does **not** automatically equal a complete rollback.

The following remains true:

- the `ESP` is outside the Btrfs snapshot boundary
- after a rollback, the boot pipeline may still need to be re-synchronized
- a bootable snapshot exists to recover and decide, not to perform magic

## Expected behavior

The `Limine` menu keeps:

- `Primary`
- `Fallback`
- `Manual recovery`

And it additionally exposes:

- the latest generated snapshot entries

## Consequences

### Positive

- recovery becomes visible at boot time
- the workflow stays coherent with the `Limine-first` direction
- `update-all` can regenerate the menu deterministically

### Negative

- permanent rollback is still a separate operator action
- menu generation still depends on healthy `Snapper` metadata

## Student-level summary

The key idea is:

- `Snapper` stores historical root states
- `Limine` exposes them as recovery entry points
- you can boot a snapshot to inspect or recover
- but final boot-chain coherence is still the responsibility of the `Margine`
  maintenance pipeline
