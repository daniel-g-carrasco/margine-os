# ADR 0035: Framework 13 AMD power baseline

## State

Accepted

## Context

On the AMD Framework 13 we are interested in two different objectives:

- good real laptop battery life;
- predictable color rendering for a system also oriented towards photography.

In the real runtime `Margine` has already validated:

- `power-profiles-daemon` with `amd_pstate` and `platform_profile`;
- panel inside `2880x1920@120`;
- `amdgpu_panel_power` exposed by `power-profiles-daemon` as an action
  separated, with explicit note "may affect color quality";
- `battery_aware` already available in `power-profiles-daemon`.

This changes the picture: there is no need to introduce a second demon that rewrites
the CPU profile continuously. Instead, we need to make a minimum policy explicit,
readable and persistent.

## Decision

`Margine v1` adopts this power baseline for AMD Framework 13:

- `power-profiles-daemon` remains the official engine of energy profiles;
- `battery_aware=true`;
- saved basic profile: `balanced`;
- `amdgpu_panel_power=false`;
- `amdgpu_dpm=false`;
- laptop lid close suspends the machine both on battery and on external power;
- docked lid close remains ignored;
- the `60/120Hz` change of the internal panel is treated separately, with
  a dedicated user service in the desktop layer;
- `VRR` and explicit refresh rate change are not confused: the first remains
  a best effort monitor support, the second is the concrete tool for
  autonomy.

The policy is versioned as the initial state of
`/var/lib/power-profiles-daemon/state.ini`, plus a `logind` drop-in at
`/etc/systemd/logind.conf.d/lid.conf`.

## Consequences

Positive:

- the power behavior is not implicit in the local state of the machine;
- mitigation for AMD panel which can distort colors becomes part
  of the project;
- the lid behavior is explicit and laptop-appropriate instead of relying on
  environment-specific defaults;
- we do not introduce an aggressive watcher that overrides manual choices
  of the user on the CPU profiles.

Negative:

- the baseline relies on `power-profiles-daemon`, so persistence is
  modeled on his `state.ini`;
- if the format of the `power-profiles-daemon` status changes in the future,
  this layer will need to be revised.

## Operational notes

On the current real system `power-profiles-daemon` is active and the policy results
already consistent, but the service is not yet `enabled` at boot. This is
a detail of the current machine, not of the `Margine` bootstrap, which instead
already enable the basic service.

For lid behavior, the intended runtime model is:

- `systemd-logind` handles the lid event and suspends;
- `hypridle` locks the session before sleep;
- on resume, the display is restored and the user returns to the locked session.
