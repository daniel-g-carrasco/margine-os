# ADR 0020 - `greetd + tuigreet` with initial autologin and immediate lock

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

For `Margine v1` the chosen path is:

- `greetd` as minimal login manager;
- `tuigreet` as fallback greeter;
- `initial_session` of `greetd` configured to start automatically
  the primary user in session `Hyprland`;
- `hyprlock` launched immediately when starting the graphics session.

In practice:

`boot -> greetd -> initial autologin -> Hyprland -> hyprlock`

If the session ends or the user logs out, the fallback reverts to:

`greetd -> tuigreet`

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

For an encrypted, single-user personal laptop, this is a compromise
acceptable and desirable.

For a multi-user machine or with stricter policies, this would not be the choice
right.

## Implementation v1

`Margine` version:

- a template of `/etc/greetd/config.toml`;
- a provisioner that renders it with the main user;
- enable by `greetd.service`.

The configuration uses:

- `default_session = tuigreet`
- `initial_session = /usr/bin/start-hyprland`

## Practical consequences

This decision gives `Margine`:

- a modern but minimal login path;
- a UX consistent with `Hyprland`;
- a clean fallback after logout;
- a clear separation from the GNOME world.

## For a student: the simple version

The point here is not "how do I get into the desktop?".

The question is: "who controls entry to the session, and with what experience?".

`greetd` is the doorman.
`tuigreet` is the reserve reception desk.
`hyprlock` is the interior door you actually see every day.