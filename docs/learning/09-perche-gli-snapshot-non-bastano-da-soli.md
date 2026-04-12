# Because snapshots alone aren't enough

This note explains something very important to understand early:

- having `Btrfs + Snapper` doesn't mean the whole system is automatically
resettable in a single gesture.

## 1. What snapshots protect

`Snapper` snapshots protect the subvolume you chose
snapshotare.

In our project, the focus is:

- root `Btrfs`

So they protect very well:

- `/etc`
- `/usr`
- structural part of `/var`
- the system state in the root filesystem

## 2. What they DON'T protect themselves

They do not automatically protect:

- la `ESP`
- i file EFI
- le `UKI`
- the binary `Limine`
- the EFI configuration already copied to the boot partition

This happens for a simple reason:

- the `ESP` does not live inside the snapshotted root subvolume.

## 3. Why this distinction is fundamental

If you don't understand it well, you risk making a dangerous mistake:

- believe that a root snapshot is enough to bring the entire machine back.

It's not enough.

The snapshot brings you back the root system.
Il boot path, invece, va:

- kept consistent;
- or regenerated.

## 4. So what are snapshots really for?

They are really useful.
They are very useful.

But they serve their right purpose:

- recover the root system;
- compare states;
- go back after updates or risky changes;
- fornire una base forte per la recovery.

They do not, by themselves, solve the entire boot chain.

## 5. Where update-all comes into play

This is where proper pipeline design comes into play.

`snap-pac` creates pre/post snapshots during `pacman`.
Then `update-all` has to take care of the rest:

- rigenerare `UKI`
- update `limine.conf`
- fare `limine enroll-config`
- firmare
- check

This is an important lesson:

- good recovery doesn't rely on just one tool;
- brings together tools with different responsibilities.

## 6. Why don't we activate the timelines right away

Because in `v1` we want to maximize the signal first.

The largest value today comes from:

- pre/post snapshot of updates;
- manual snapshots before risky interventions.

Automatic timelines on the root risk creating a lot of noise even earlier
that we closed the rest of the pipeline well.

## 7. The final rule to remember

If one day you ask yourself:

- "I have a snapshot, so I'm totally safe?"

the correct answer is:

- you are much safer on the root filesystem;
- but the consistency of the boot path must still be managed.

This distinction is one of the points that separates a "flashy" setup from a
really solid architecture.
