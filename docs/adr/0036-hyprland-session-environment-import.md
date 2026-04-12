# ADR 0036: explicit import of the Hyprland environment in the `systemd --user` manager

## State

Accepted

## Context

`Margine` uses `Walker` as the default launcher and `Elephant` as the data backend.
`Elephant` can launch applications through `systemd-run --user --scope`.

This creates an important distinction:

- the user terminal directly sees the rich environment of the session
  Hyprland;
- the `systemd --user` manager does not automatically see all the variables of the
graphic session;
- apps launched from `Walker -> Elephant -> systemd-run --user --scope` can
therefore receive a poorer or inconsistent graphic context.

The local case of `wayland-scroll-factor` made the problem more evident, but
it is not the architectural root cause to be fixed in `Margine`.

## Decision

`Margine` explicitly imports the essential graphical environment of the session
Hyprland in the `systemd --user` manager and in the D-Bus activation context.

The solution is:

- script versioned `margine-import-session-environment`;
- running as first `exec-once` of session in `hyprland.conf`;
- starting the launcher service immediately after importing the environment;
- joint use of:
  - `systemctl --user import-environment`
  - `dbus-update-activation-environment --systemd`

The candidate variables are:

- `DISPLAY`
- `WAYLAND_DISPLAY`
- `XDG_CURRENT_DESKTOP`
- `XDG_SESSION_TYPE`
- `XDG_SESSION_DESKTOP`
- `DESKTOP_SESSION`
- `GDK_BACKEND`
- `MOZ_ENABLE_WAYLAND`
- `_JAVA_AWT_WM_NONREPARENTING`
- `HYPRLAND_INSTANCE_SIGNATURE`
- `XDG_RUNTIME_DIR`

The script also applies sensible defaults when the session doesn't have it yet
explained some values:

- `XDG_CURRENT_DESKTOP=Hyprland`
- `XDG_SESSION_TYPE=wayland`
- `XDG_SESSION_DESKTOP=hyprland`
- `DESKTOP_SESSION=hyprland`
- `GDK_BACKEND=wayland`
- `MOZ_ENABLE_WAYLAND=1`
- `_JAVA_AWT_WM_NONREPARENTING=1`

## Because here and not elsewhere

The point chosen is Hyprland itself, not `greetd`.

Reason:

- `greetd` can start the session, but it doesn't know how variables yet
  `WAYLAND_DISPLAY` o `HYPRLAND_INSTANCE_SIGNATURE`;
- those variables only reliably exist after Hyprland has created
really the session;
- therefore the first architecturally correct point to import them is
the initial start of the Hyprland session.

## Consequences

Positive:

- `Walker` and `Elephant` stop depending on local workarounds;
- the `systemd --user` manager receives the same essential graphical context that
sees the session shell;
- Graphical D-Bus activations also remain consistent.
- `Elephant` is no longer enabled as a persistent session service:
it is started on-demand by the launcher after importing the environment, not so
he may leave too soon.

Negative:

- the fix depends on an explicit step in `hyprland.conf`;
- if in the future `Margine` changes session entrypoint, this point will
reevaluated.
