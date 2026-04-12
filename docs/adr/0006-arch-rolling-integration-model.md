# ADR 0006 - Integration model with Arch rolling

## State

Accepted

## Why this ADR exists

An important question soon emerged:

- Does `Margine` need to be updated every time Arch or the kernel is updated?

If this question remains implicit, the project risks being interpreted in
two wrong ways:

- like a frozen distro to be rebuilt with each update;
- or as a collection of dotfiles disconnected from the reality of rolling
  release.

Neither interpretation is correct.

## Problem to solve

`Margine` vuole essere:

- riproducibile;
- educational;
- maintainable;
- compatibile con Arch rolling.

This means that we must clearly distinguish:

- who provides the packages;
- who defines the assembly of the system;
- when the `margine-os` repo should be updated;
- when you just need to update the installed system.

## Decision

`Margine` is NOT a frozen fork of Arch.

`Margine` is an assembly and maintenance layer on top of Arch rolling, composed
da:

- package manifest;
- configuration files;
- bootstrap and post-install scripts;
- maintenance hooks;
- documentation and ADR.

## What this means in practice

### Installation

From a clean Arch base:

- `pacman` installs the most current packages available at that time
official repositories;
- our scripts apply the `Margine` form on top of those packages.

So the `margine-os` repo is not for "providing Arch packages".
It is used to define how those packages are combined.

### Routine system update

An already installed `Margine` system updates like a normal Arch:

- package updates;
- regeneration of necessary local artefacts;
- snapshot and recovery according to the project policy.

There is no need to modify the `margine-os` repo with each regular update.

### When the repo needs to be updated instead

The `margine-os` repo must be updated when one of these layers changes:

- name or availability of a package;
- path or format of a project-managed file;
- behavior of key tools, such as `mkinitcpio`, `sbctl`, `Limine`,
  `systemd-cryptenroll`;
- project policy;
- choice of a new component;
- installation or maintenance script.

In other words:

- Arch is constantly changing;
- `Margine` only changes when it needs to adapt or improve its architecture.

## Compatibility rule

For `v1`, `Margine` will follow this simple rule:

- we support the current state of the official Arch repositories;
- we do not promise compatibility with arbitrary and remote snapshots from the past.

This is consistent with an Arch rolling based project.

## Practical consequences

### Advantages

- we don't have to "release a distro" with every Arch update;
- we can always install from updated packages;
- maintenance remains focused on what we really control;
- the project remains small and readable.

### Costs

- we need to keep an eye on upstream changes that impact ours
automation;
- every now and then an ADR or a script will need to be updated;
- the project needs to be tested against the current Arch, not just well written.

## Relationship with `update-all`

The `update-all` script does not become an alternative package manager.

Its correct role will be:

- orchestrate updates, snapshots, `UKI` regeneration, signatures and verifications;
- do not replace the package source.

The source of the packages remains:

- `pacman` for official repositories;
- AUR only where explicitly permitted by the project.

## For a student: the simple version

If we explain it in the most direct way possible:

- Arch supplies the bricks;
- `Margine` decides how to mount them;
- when Arch updates a brick, it usually just updates the system;
- we only touch the `margine-os` repo when the way we mount i changes
bricks.

This is the difference between:

- a frozen distro;
- and a reproducible framework on top of a rolling release.
