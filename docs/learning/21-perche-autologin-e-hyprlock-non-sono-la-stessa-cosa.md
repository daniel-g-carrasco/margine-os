# Because autologin and `hyprlock` are not the same thing

When designing access to a graphical system, it's easy to think:

> "If `hyprlock` then appears, then it is the same as logging into the greeter."

It is not true.

## Two different models

### Model A

`greetd -> tuigreet -> autenticazione -> sessione`

Here the user is authenticated *before* the session starts.

### Model B

`greetd -> autologin -> Hyprland -> hyprlock`

Here the session starts immediately, but is blocked immediately by
lockscreen.

## Why then choose model B?

Because the `Margine` project is designed, at least in `v1`, to:

- a personal laptop;
- only one main user;
- encrypted disk;
- high priority to aesthetic and operational coherence.

In this context, model B offers:

- a more uniform UX;
- a single visual language;
- less dependence on a "bulky" display manager.

## What is lost

Model B should not be described as if it were identical to Model A.

Si perde:

- a more rigid separation between boot phase and session phase;
- a more classic authentication boundary;
- a semantics more suitable for shared machines.

## Why then also keep `tuigreet`

Because we need a clean fallback.

`greetd` has two concepts:

- `default_session`: the normal greeter;
- `initial_session`: the initial session launched once per boot.

This allows you to have both:

- initial autologin for main user;
- `tuigreet` available after logout or when autologin is not the path
  right.

## The real lesson

When you configure a login path you are not just choosing "a program that opens
the desktop".

You are choosing:

- where authentication takes place;
- how much trust you give to the context of the machine;
- what experience do you want to make normal;
- what fallback do you want to leave when something changes.

For `Margine`, the choice is: personal machine, session consistent, fallback
clean.