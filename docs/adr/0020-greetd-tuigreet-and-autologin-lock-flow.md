# ADR 0020 - `greetd + tuigreet` login baseline

## State

Accepted

## Why this ADR exists

Up to this point `Margine` had left the choice of the final login path open:

- `greetd`
- TTY puro
- other display manager

Meanwhile, real-world use of the machine made clear a strong preference:

- nothing `GDM`;
- no double-step login manager + lockscreen with different aesthetics;
- experience consistent with `Hyprland` and `hyprlock`.

## Problem to solve

We want a simple and uniform UX, but without turning the bootstrap into one
fragile or too "magical" chain.

You therefore need to decide:

1. who starts the session;
2. whether a fallback greeter still exists;
3. How do you reconcile autologin with the lockscreen.

## Decision

For `Margine v1` the default chosen path is:

- `greetd` as minimal login manager;
- `tuigreet` as the primary greeter;
- no `initial_session` by default;
- `hyprlock` remains the session lockscreen after login, resume, and manual lock.

In practice:

`boot -> greetd -> tuigreet -> Hyprland`

The older fast path is still available only as an explicit opt-in:

`boot -> greetd -> initial autologin -> Hyprland -> hyprlock`

## Why not pure TTY

Pure TTY is simpler in theory, but worse in UX for the real target
of `Margine`:

- personal laptop;
- reinstallable;
- oriented for daily use;
- with attention to aesthetics and coherence.

With `greetd` we get:

- clean session management;
- readable fallback;
- no dependency on heavy display managers;
- better alignment with `Hyprland`.

## Why not `GDM`

`GDM` fixes login, but brings with it a GNOME world that `Margine` doesn't
wants to use as main infrastructure.

Furthermore the combination:

`GDM -> login -> Hyprland -> hyprlock`

it duplicates the moment of access and breaks the visual uniformity.

## Important clarification: autologin and lockscreen are not the same thing

This choice is intentional, but it is understood well:

- `tuigreet` authenticates *before* the session;
- `autologin + hyprlock` enters the session and then blocks it immediately.

For an encrypted, single-user personal laptop, `autologin-lock` can still be a
valid convenience mode, but it is no longer the installation default.

For a multi-user machine or with stricter policies, this would not be the choice
right.

## Implementation v1

`Margine` version:

- a template of `/etc/greetd/config.toml`;
- a provisioner that renders it with the main user;
- enable by `greetd.service`.

The configuration uses:

- `default_session = tuigreet`
- no `initial_session` in the default `tuigreet-only` mode
- optional `initial_session = /usr/bin/start-hyprland` only when
  `--login-mode autologin-lock` is explicitly selected

## Practical consequences

This decision gives `Margine`:

- a modern but minimal login path;
- a UX consistent with `Hyprland`;
- no hidden autologin on bare metal or VM installs;
- a clear separation from the GNOME world.

## For a student: the simple version

The point here is not "how do I get into the desktop?".

The question is: "who controls entry to the session, and with what experience?".

`greetd` is the doorman.
`tuigreet` is the reserve reception desk.
`hyprlock` is the interior door you actually see every day.
