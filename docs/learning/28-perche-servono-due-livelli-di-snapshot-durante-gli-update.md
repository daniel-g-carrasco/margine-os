# Why do you need two levels of snapshots during updates

If you want "Manjaro" or "Omarchy" behavior, the real requirement is
this:

- have a snapshot right before touching the system.

But in `Margine` we don't stop there.

## Level 1: global pre-update snapshot

As soon as `update-all` starts, we create an explicit snapshot of the root.

This snapshot represents:

- the state before the entire maintenance;
- a simple to understand return point;
- the "big red button" before starting.

## Level 2: pacman pre/post snapshot

Within the same flow, `snap-pac` continues to create pre/post snapshots for the
transaction `pacman`.

These are more granular:

- they help to understand what happened around the change of packages;
- they remain useful even if `pacman` is used outside of `update-all`.

## Why not choose just one

If you only use global snapshot:

- you lose detail on the `pacman` transaction.

If you only use `snap-pac`:

- you have no clear return point before AUR, Flatpak, firmware and boot
  regeneration.

So in `Margine` we use both.

## The simple formula

- global snapshot for entire maintenance;
- granular snapshots for `pacman`.

It is precisely this combination that makes the flow more robust.