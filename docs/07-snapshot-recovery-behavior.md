# Snapshot Recovery Behavior

This is the operational behavior of `Margine` when booting a `Snapper` snapshot
from `Limine`.

## What a snapshot entry does

Each generated snapshot entry boots:

- the shared `margine-recovery.efi` UKI
- the selected root snapshot subvolume
- in read-only mode
- on `graphical.target`

That means a snapshot entry is a **graphical recovery boot**, not a permanent
rollback.

## What happens after booting a snapshot

When you choose a snapshot entry in `Limine`:

1. the machine boots from `@snapshots/<N>/snapshot`
2. that snapshot is mounted read-only
3. the normal desktop path can still come up because the entry targets
   `graphical.target`

This lets you inspect an older system state in a safer way.

## How entries get refreshed after maintenance

`update-all` is also responsible for keeping the boot menu aligned with the
current snapshot set.

During a successful maintenance run it now:

1. creates the explicit pre-update snapshot
2. auto-detects the installed root UUID
3. auto-detects the installed LUKS UUID
4. auto-detects the installed `limine.conf` target
5. regenerates the snapshot entries under `/Recovery`

So the recovery menu is not meant to be static. It is refreshed as part of the
normal maintenance pipeline.

## What does not happen automatically

Booting a snapshot does **not**:

- promote that snapshot to the live root
- replace `@` with the snapshot
- rewrite the default boot entry
- make the rollback permanent by itself

If you reboot and choose `Primary`, the machine boots the normal root subvolume
again.

## Why `Manual recovery` is different

`Manual recovery` is intentionally more conservative.

It exists as the lower-level path when you want recovery behavior without
depending on the full graphical session.

Snapshot entries are optimized for readability and fast inspection.
`Manual recovery` remains the safer fallback path.

## Naming of generated entries

Generated snapshot entries use:

- entry title: snapshot number + creation date/time
- entry comment: fuller metadata, including source and recovery mode

This keeps the visible menu compact while still exposing richer details in the
secondary UI area of `Limine`.

## How permanent rollback should be treated

The current design treats snapshot boot as:

- inspection
- validation
- temporary recovery

Permanent rollback is still a conscious operator action and should be handled as
a separate procedure.
