# ADR 0037 - Snapshot Recovery Operating Model

## Status

Accepted

## Context

By this point, `Margine` had already implemented:

- generated `Limine` entries for root snapshots
- a recovery `UKI`
- graphical boot support for snapshot entries
- a separate `Manual recovery` path

What was still easy to misunderstand was the operating model itself.

Users could reasonably assume that:

- booting a snapshot permanently rolls the system back
- selecting a snapshot rewrites the live root automatically
- `Primary` would keep booting that snapshot afterwards

That is not how the current system behaves.

## Decision

`Margine v1` treats snapshot boot as a **temporary read-only recovery session**,
not as an automatic permanent rollback.

The model is:

1. boot the selected snapshot entry
2. inspect or validate the old system state
3. if a full rollback is desired, perform it explicitly from a writable
   maintenance environment
4. boot `Primary` again on the promoted root

Snapshot entries are therefore:

- read-only
- graphical
- recovery-oriented

They are not self-promoting rollback entries.

## Why

This model is intentionally conservative.

It separates:

- "I need to get into a known-good older state right now"
- from
- "I want that older state to become my normal system again"

That separation reduces ambiguity and avoids silent mutation of the live root.

## Operational consequence

After booting a snapshot:

- rebooting into `Primary` returns to the normal `@` root
- no permanent rollback has happened yet
- the operator must explicitly promote the chosen snapshot if that is desired

## Storage implication

On a full `Margine` installation, the target Btrfs subvolume layout makes this
model cleaner because:

- `@` is the mutable system root
- `@home` is separate
- `@snapshots` is separate
- several runtime-heavy paths are isolated

On legacy or partially aligned hosts, rollback still works, but the isolation
quality is lower.

## Documentation requirement

Because this behavior is easy to misread, `Margine` must keep an explicit
operator document for permanent rollback procedure and must not rely on menu
labels alone.
