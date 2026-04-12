# ADR 0008 - Policy snapshot and system update

## State

Accepted

## Why this ADR exists

Now that the project has:

- `Btrfs`
- `Snapper`
- `Limine`
- `UKI`
- separate `ESP`

we need to decide how we really want to use snapshots during updates.

The correct question is not:

- "do we want snapshots?"

That's already closed.

The real question is:

- "which snapshots do we take, when, with which tool, and for which paths?"

## Problem to solve

There are four needs to keep together:

1. have pre/post snapshots during pacman updates;
2. do not depend on a single user manual habit;
3. do not fill the system with noisy and low-value snapshots;
4. Don't fool yourself into thinking that Btrfs snapshots also cover `ESP`.

This last point is crucial:

- `Snapper` snapshots protect the `Btrfs` root;
- they do not automatically protect `ESP/EFI/...`, which lives outside the snapshotted
  volume.

## Decision

For `Margine v1` we adopt this policy.

## 1. Base tool

We adopt:

- `snapper`
- `snap-pac`

Reason:

- `snapper` is the snapshot and cleanup engine;
- `snap-pac` is the safety net that creates pre/post snapshots for transactions
`pacman`, regardless of how `pacman` is invoked.

This is important because it avoids a very common fragility:

- lose snapshots just because you once updated with `pacman`
direct instead of with the "official" script.

## 2. Automatically snapshotted configuration

In `v1` we automatically snapshot only:

- `root` configuration

We do not automatically snapshot:

- `home`
- `data`
- subvolumes per VM
- subvolumes per container

Reason:

- automatic snapshots are mainly used for system recovery;
- User data and highly mutating workloads have different policies.

## 3. Type of automatic snapshots

The mandatory automatic snapshots in `v1` are:

- explicit initial snapshot at startup of `update-all`;
- pre/post transactions `pacman`

This means that the final model is:

- a "maintenance start" snapshot before the entire update;
- granular pre/post snapshots of the `pacman` transaction.

These snapshots will be the normal recovery path after update.

In addition, the initial bootstrap of the system must leave at least:

- the `root` config of `snapper` actually installed;
- `snap-pac` configured;
- an initial baseline snapshot of the newly installed system.

## 4. Timeline

In `v1` we disable automatic timelines on the root.

Choice:

- `TIMELINE_CREATE=no`
- `TIMELINE_CLEANUP=no`

Reason:

- we want high signal snapshots;
- the main value today is recovery from updates and maintenance;
- hourly timelines on the root quickly generate noise.

This does not exclude enabling them in the future.
It just means that they are not part of the baseline.

## 5. Cleanup

We keep:

- cleanup `number`
- cleanup `empty-pre-post`

Recommended initial policy for `root`:

- `NUMBER_CLEANUP=yes`
- `NUMBER_LIMIT=30`
- `NUMBER_LIMIT_IMPORTANT=12`
- `EMPTY_PRE_POST_CLEANUP=yes`

Reason:

- we keep a useful history of transactions;
- we keep snapshots considered important a little longer;
- we automatically eliminate pre/post pairs without relevant differences.

## 6. Important snapshots

We want some updates to be clearly recognizable as important.

For this reason, the most sensitive packages must mark snapshots with:

- `important=yes`

Recommended starter packages:

- `linux`
- `linux-lts`
- `amd-ucode`
- `systemd`
- `mkinitcpio`
- `cryptsetup`
- `sbctl`
- `limine`
- `snapper`

Furthermore, a:

- `pacman -Syu`

should be considered important on a semantic level, even if the packages involved
they are not individually filtered.

## 7. Role of update-all

`update-all` remains the canonical update path of `Margine`.

Its correct role will be:

- orchestrate the update;
- create an explicit snapshot at the beginning of the stream;
- leave the pre/post snapshots of the `pacman` transaction to `snap-pac`;
- handle the extra steps of `Margine`, such as:
  - `UKI` regeneration
  - refresh `limine.conf`
  - `limine enroll-config`
  - sign and verify

In other words:

- `update-all` creates the return point "before all maintenance";
- `snap-pac` protects root during `pacman`;
- `update-all` protects the consistency of the complete pipeline of `Margine`.

## 8. Fundamental rule about ESP

Root snapshots are NOT a replacement for boot path recovery.

The `ESP` sits outside the root snapshot.

Therefore, after an update or after a rollback, the consistency of:

- `Limine`
- `UKI`
- config EFI
- signatures

must be maintained via deterministic regeneration, expecting only one
Btrfs snapshot also fixes the `ESP`.

This is an architectural rule, not an operational detail.

## 9. What does rollback mean in this v1

In `v1`, rollback mainly means:

- return to a previous state of the root filesystem;
- then realign or regenerate the boot path if necessary.

It doesn't mean:

- "the whole system, including the `ESP`, magically goes back on its own".

## 10. Warning about pacman database

The `snap-pac` documentation reminds you of an important point:

- pre snapshots are created after any sync of the pacman database.

So a filesystem rollback after `pacman -Syu` does not automatically equate to
a "perfect rewind" of the entire pacman state.

This means that snapshots are a very strong recovery tool, but
they should not be mistaken for a pass towards random partial upgrades.

## 11. Manual snapshots

For risky jobs that DO NOT go through `pacman`, the correct policy is:

- create an explicit manual snapshot

Examples:

- heavy modification of `/etc`
- interventions on auth, boot or encryption
- local migrations outside the normal update flow

This can be orchestrated in the future by a dedicated script.

## For a student: the simple version

If we reduce it to the essentials:

- `update-all` opens with a pre-update snapshot;
- ``snap-pac` acts as a granular airbag for `pacman`;
- `update-all` acts as conductor;
- snapshots protect the root;
- the `ESP` is recovered with regeneration, not with magic;
- no noisy timelines in `v1`.
