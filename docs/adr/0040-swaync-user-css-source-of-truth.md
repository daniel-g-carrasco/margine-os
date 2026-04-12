# ADR 0040 - SwayNC User CSS Source Of Truth

## Status

Accepted

## Context

`SwayNC` was rendering differently across:

- the host session
- the VM session
- newly provisioned systems

The root cause was not only the project CSS itself. `swaync` was also loading
the distro-provided system stylesheet from `/etc/xdg/swaync/style.css`.

That created a bad failure mode:

- project CSS looked correct in the repository
- runtime rendering still drifted
- small layout regressions were difficult to reason about

The visible symptom was the notification-card block inside the control center
being horizontally misaligned relative to the title, DND row, and MPRIS block.

## Decision

`Margine` treats the versioned user stylesheet as the canonical SwayNC theme.

The user service must start `swaync` with:

- `--skip-system-css`

This is implemented through a user systemd drop-in at:

- `~/.config/systemd/user/swaync.service.d/override.conf`

The control-center notification list remains tuned in the versioned project CSS.
The current accepted horizontal alignment is:

- `.control-center-list { margin: 0 2px; }`

## Why

Skipping the distro stylesheet removes an uncontrolled second source of layout
rules.

That gives one predictable rendering path:

- repository CSS
- provisioned user config
- runtime rendering

When visual regressions happen, debugging stays local to the project stylesheet
instead of being split across project and distro layers.

## Consequences

### Positive

- host, VM, and fresh installs render from the same CSS source
- layout debugging becomes deterministic
- distro updates are less likely to silently perturb the control-center layout

### Negative

- project CSS now owns more of the final rendering responsibility
- if the project stylesheet breaks, the system no longer falls back to a nicer
  distro default

## Operational rule

If `SwayNC` looks different from the repository expectation, check these items
first:

1. `systemctl --user status swaync.service --no-pager`
2. whether the service command line includes `--skip-system-css`
3. whether `~/.config/swaync/style.css` matches the provisioned project version
