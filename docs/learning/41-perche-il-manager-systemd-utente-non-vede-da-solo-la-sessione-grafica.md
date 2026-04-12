# Because the `systemd --user` manager doesn't see the graphics session itself

This problem is easy to misunderstand.

## Terminal and user manager are not the same thing

When you run a terminal command, the child process inherits the environment
of the shell:

- `WAYLAND_DISPLAY`
- `DISPLAY`
- `HYPRLAND_INSTANCE_SIGNATURE`
- variabili dei toolkit

However, when an app is launched by:

- `systemd-run --user --scope`

the environment source is not your shell. It's manager `systemd --user`.

So the right question is not:

- "Does the terminal see the variable?"

ma:

- "Does the user manager know you?"

## Because Walker and Elephant bring out the bug

Nel workflow di `Margine`:

- `Walker` is the launcher;
- `Elephant` acts as the backend;
- the final launch can go through `systemd-run --user --scope`.

If `systemd --user` doesn't know the correct graphics session, the apps:

- they may not open;
- may open inconsistently;
- they may appear healthy from the terminal but not from the launcher.

## Because `greetd` is not enough

`greetd` starts the session, but cannot materialize variables in advance
which only exist when Hyprland has already really left.

Per esempio:

- `WAYLAND_DISPLAY`
- `HYPRLAND_INSTANCE_SIGNATURE`

For this reason the correct point is not "before Hyprland", but "immediately after
Hyprland session bootstrap".

## The right solution

The solution is not to fix app by app.

The right solution is:

1. take the essential variables from the real Hyprland session;
2. import them into the `systemd --user` manager;
3. also import them into the D-Bus activation environment;
4. do this very early in the session bootstrap.

In practice:

- `systemctl --user import-environment ...`
- `dbus-update-activation-environment --systemd ...`

## What really validates the fix

Il fix is valido quando:

- `systemctl --user show-environment` contains the same essential variables
  of the session shell;
- `Walker` launches apps with the same essential graphic context as the terminal.