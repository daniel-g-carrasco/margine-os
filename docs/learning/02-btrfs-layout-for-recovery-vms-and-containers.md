# Because this Btrfs layout is done well

This note explains the meaning of the layout chosen in ADR 0003.

It doesn't just mean "put these subvolumes".
He wants you to understand the criterion.

## 1. The right question

When designing a Btrfs layout, the question is not:

- "how many subvolumes can I create?"

The right question is:

- "what do I really want a system snapshot to contain?"

If the answer is confusing, the layout will be confusing.

## 2. Due categorie diverse

In the `Margine` project we distinguish two large families of data.

### System status

This is what you want to be able to rollback as a single block:

- `/etc`
- `/usr`
- `/opt`
- database pacman
- structural part of `/var`

This lives in the root snapshot.

### High mutation data

That's what you don't want messing up the snapshots:

- cache
- log
- tmp persistenti
- user home
- photos and large datasets
- dischi VM
- storage containers

This needs to be separated.

## 3. Because `@home` is separate

Because system rollbacks and user data are not the same thing.

If you break the system, you want to roll back the system.
You don't want to automatically treat your home as part of the same snapshot.

## 4. Why `@var_log`, `@var_cache` and `@var_tmp`

Because they are noisy places.

If you leave them inside the root snapshot:

- snapshots grow poorly;
- rollback is dirty;
- the signal-to-noise ratio worsens.

## 5. Why `@data`

`/data` serves as a user-managed space for heavy or long-lived datasets.

In our case it can become the right place for:

- photos and archives;
- large working material;
- user disk images;
- export, backup locali, staging.

This saves you from turning `/home` into a giant, unreadable blob.

## 6. Why separate VMs and containers

VMs and containers do a very simple thing:

- they write a lot;
- they change often;
- they become large;
- they quickly pollute snapshots.

This is why we separate them:

- `/var/lib/libvirt`
- `/var/lib/machines`
- `/var/lib/containers`

Not because he "does business".
But because it is the right way to prevent the operating system and workloads from doing so
drag each other along.

## 7. Because `NOCOW` only in specific points

`NOCOW` is not a magical power-up.
It is a specific tool.

Ha senso su:

- disk images of the VMs

Makes less sense as a total hammer on:

- all storage containers

This is an important lesson:

- optimizing well does not mean deactivating features at random;
- optimizing well means understanding where behavior really changes.

## 8. Why don't we separate `/opt`

Because files installed by packages also live there.

If you roll back the system but leave `/opt` out, you risk creating misalignment
tra:

- package database
- real state of the filesystem

This is a classic example of "wrong separation".

## 9. Why don't we separate `/var/lib/pacman`

Because the package database must follow the system.

If you rollback root but the pacman database remains ahead or behind
at snapshot, you get a system that is difficult to reason about.

## 10. Why `compress=zstd:3`

Because it gives us a good compromise:

- useful compression;
- reasonable CPU cost;
- real benefit on modern laptop.

We're not looking for the most aggressive mount option in the world.
We're looking for the one that makes the most sense.

## 11. Why `fstrim.timer`

Because on SSD drives it's a clean and predictable choice.

In general, in this project we prefer:

- clear mechanisms;
- less "micro-tuning" inside `fstab`;
- more behavior that is easy to explain.

## 12. The take-home lesson

A well-done Btrfs layout is not born from personal taste.

It comes from a simple question:

- what data should roll back together?

Everything else comes later.
