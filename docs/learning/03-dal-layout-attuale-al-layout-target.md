# Dal layout attuale al layout target di Margine

This note compares two things:

- the layout you have on the machine today;
- the layout we want for `Margine`.

The goal is not to say that the current system is "wrong."
The objective is to understand why an already good base must be refined when the project
becomes more ambitious.

## 1. The layout you have today

Today the machine already uses a clean structure:

- separate `ESP` su `/boot`
- rest of the disk in `LUKS2`
- `Btrfs` inside the encrypted volume
- subvolumes for:
  - `/`
  - `/home`
  - `/.snapshots`
  - `/var/cache`
  - `/var/log`

This is important: we are not starting from chaos.
We are starting from an already sensible base.

## 2. Why then change?

Because the goals of `Margine` are more stringent than those of an installation
normal.

Together we want:

- clean snapshots;
- readable rollback;
- boot snapshot-friendly;
- tidy space for heavy datasets;
- future use with VMs and containers;
- predictable behavior even with a cool head.

The current layout covers the "tidy personal desktop" case well.
Il layout target deve coprire anche il caso "workstation personale con recovery
seria".

## 3. What we care about the current layout

Keeping what is already good is a discipline.

We don't change:

- `ESP + LUKS2 + Btrfs`
- `@` per `/`
- `@home` per `/home`
- `@snapshots`
- `@var_cache`
- `@var_log`

This continuity is useful because:

- reduces cost-free complexity;
- keeps the project readable;
- it allows you to recognize the relationship between the current machine and the future system.

## 4. What we add and why

### `@var_tmp`

It is used to remove persistent temporaries from the root snapshot.

Lesson:
- not everything in `/var` is "system state";
- some areas must be isolated because they dirty the rollbacks.

### `@root`

It serves to separate the administrator's operating space.

Lesson:
- files, notes, scripts, or `root` keys are not the same as the system
operating;
- a system rollback doesn't have to drag everything that is with it
passed through `/root`.

### `@srv`

It is used to give an orderly place to locally served data.

Examples:

- export locali;
- directory servite in rete;
- material that is not a system but not even a "user home".

### `@data`

It is one of the most important points.

It serves to prevent `/home` from becoming the universal container of everything:

- photo;
- large archives;
- staging;
- export;
- user VM images;
- backup locali.

Lesson:
- a good layout doesn't just separate the system;
- it also separates large volumes of data to give you more mental control.

## 5. Why VMs and containers deserve their own subvolumes

VMs and containers are write-intensive workloads.

If you leave them in the root snapshot:

- snapshots grow too large;
- rollback becomes less readable;
- the boundary between "system" and "workload" becomes blurred.

This is why `Margine` separates:

- `/var/lib/libvirt`
- `/var/lib/machines`
- `/var/lib/containers`

### Important distinction: rootful vs rootless

This is a subtlety worth learning well.

`Podman` rootful tends to come under:

- `/var/lib/containers`

`Podman` rootless tende a stare sotto:

- `~/.local/share/containers`

So:

- rootful containers should be treated as system workloads and separated;
- rootless containers are part of user life and are naturally in
  `@home`.

## 6. Why don't we keep adding subvolumes endlessly

Because more subvolumes does not automatically mean more quality.

A layout degenerates when each directory becomes a candidate for being separated.

The healthy rule is this:

- it just separates what needs to live or rollback differently.

This is why we DO NOT separate, for example:

- `/opt`
- `/var/lib/pacman`
- much of `/usr` and `/etc`

Lesson:
- separating badly is worse than not separating at all.

## 7. Why `compress=zstd:3`

The lesson here is not "just use this option".

The lesson is:

- choose mount options that make operational sense;
- avoid aesthetic or benchmark tuning.

`compress=zstd:3` makes sense because:

- improves storage efficiency;
- has a reasonable CPU cost;
- it remains an explainable choice on a modern laptop.

## 8. What really makes this layout better

The number of subvolumes doesn't make it better.

What makes it better is that it clearly defines the boundaries between:

- operating system;
- user data;
- cache and noise;
- virtualized workloads;
- voluminous datasets.

This is real architecture.
The rest is just syntax.

## 9. The final rule to remember

If one day you have to change the layout yourself, always start from this question:

- "does this data need to be rolled back with the system?"

If the answer is:

- yes -> they are probably in the root snapshot
- no -> they probably deserve a separate subvolume
