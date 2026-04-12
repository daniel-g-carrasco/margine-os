# ADR 0018 - Guided wrapper for installation from live ISO

## State

Accepted

## Why this ADR exists

`Margine` scripts are now mature enough to cover:

- storage provisioning;
- bootstrap live ISO;
- bootstrap in chroot;
- user provisioning.

However, an important usability point was missing:

- a guided entrypoint, step by step.

## Problem to solve

A set of robust scripts still doesn't equate to a good experience
of installation.

Many users expect:

- ordered questions;
- final summary;
- clear distinction between destructive and non-destructive modes;
- simple instructions to follow even months later.

## Decision

Per `Margine v1` introduciamo:

- `scripts/install-live-iso-guided`

This script does not replace the underlying wrappers and scripts.

He uses them in a guided way.

## Methods envisaged

The first version supports two modes:

- `erase-disk`
- `mounted-target`

The first uses `install-live-iso`.

The second uses `bootstrap-live-iso` on an already mounted target.

## Adjust UX

The UX of the `v1` remains deliberately simple:

- text prompts in shell;
- no mandatory dependencies on external `dialog`, `gum` or TUIs;
- final summary before execution.

## Adjust password

If `openssl` is available, the wrapper can generate the password hash on the fly
user.

If it is not, or if the user chooses not to set it immediately, the flow remains
valid but requires a trailing `passwd`.

## Practical consequences

This choice gives us:

- an experience already much closer to `archinstall`;
- zero extra UX dependencies;
- easier to remember future reinstallation.

## For a student: the simple version

We built the engine first.

Now we are putting a readable dashboard in front of the engine.