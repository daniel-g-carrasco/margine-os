# ADR 0014 - Bootstrap from live ISO in two steps

## State

Accepted

## Why this ADR exists

Ora `Margine` ha già:

- executable manifests;
- manifest-driven installer;
- boot/trust pipeline;
- initial bootstrap of `Secure Boot`.

However, the first real entry point from a clean installation is missing:

- bootstrapping from live ISO.

## Problem to solve

ISO live environment and target system are not the same thing.

If we treat them as a single context, we end up mixing:

- operations that must take place on `/mnt`;
- operations that make sense only within the target system;
- logic more difficult to understand and test.

## Decision

For `Margine v1`, the installation bootstrap is divided into two phases:

1. ISO live phase
2. chroot phase

## Phase 1 - Live ISO

The live ISO phase only deals with:

- check the mounted target;
- install the first minimum set of packages with `pacstrap`;
- generate `fstab`;
- copy the `margine-os` repo into the target;
- optionally enter the chroot and pass the baton to phase 2.

## Phase 2 - Chroot

The chroot phase deals with:

- basic system configuration;
- manifest-driven installation of remaining layers;
- enable fundamental services;
- preparing the system for the next boot and desktop steps.

## Minimum set rule for pacstrap

In `v1`, `pacstrap` will not install all layers.

It will install only the minimum layer required to enter a useful `chroot`:

1. `base-system`

Hardware, security, desktop, and application layers remain in phase 2.

Reason:

- stage 1 should produce a valid target root, not a partially configured final system;
- hook-heavy packages such as `snap-pac` do not belong in `pacstrap`, where they
  can emit misleading errors inside the bootstrap context;
- graphics and gaming packages in stage 1 can leave stale state behind and make
  reruns harder to reason about.

## Handoff rule

Phase 1 must not duplicate the logic of phase 2.

Instead, it must:

- copy the repo;
- call a script inside the target;
- pass it the necessary parameters.

## Rule of prudence

The `v1` bootstrap doesn't do this yet:

- automatic partitioning;
- automatic LUKS/Btrfs setup;
- end user creation;
- full bootloader installation.

Those parts will come later, in separate blocks.

## Practical consequences

This choice gives us:

- a small and readable ISO live script;
- a more testable chroot phase;
- fewer hidden hires;
- a good basis for growing without redoing everything.

## For a student: the simple version

Pensa così:

- live ISO sets the table;
- chroot really cooks the system.

If you try to do everything in the live ISO, the code gets dirty right away.
