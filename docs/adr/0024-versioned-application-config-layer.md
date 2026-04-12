# ADR 0024 - Versioned layer of application configurations

## State

Accepted

## Context

After the base layer, connectivity and desktop, we need to decide how
manage daily applications.

Not all should be treated the same:

- some are worn almost flat;
- others are better managed with policy;
- others remain the subject of future review.

## Decision

For `Margine v1` the versioned application layer includes:

- `Neovim` / `LazyVim` as versioned user configuration;
- `Kitty` as versioned user configuration;
- `mimeapps.list` cleaned and normalized;
- `user-dirs.*` as Italian baseline;
- `update-all` installed globally in `/usr/local/bin/update-all`;
- `update-all-launcher` as a small user wrapper;
- `Firefox` configured via system policy, not via copied profile.

## Specific choices

### Firefox

`Firefox` is configured with `/etc/firefox/policies/policies.json`.

The baseline is deliberately moderate:

- disabling telemetry;
- disabling studies;
- Pocket removal;
- no prompts on the default browser;
- simplified home without sponsored elements.

This is an "enforced but not too much" baseline:

- defines the basic behavior;
- does not block the browser in a corporate way;
- does not claim to replace user customization.
- does not introduce, in `v1`, aggressive browser-specific color tweaks
  management.

### Neovim

`LazyVim` enters as a versioned explicit configuration.

Reason:

- it's textual;
- it is readable;
- it's really part of the daily workflow;
- it's easy to edit and understand.

### Kitty

`Kitty` is treated as a simple, readable, and reproducible config.

### MIME and user dirs

They are normalized, not blindly copied:

- no `userapp-*` generated;
- no stale references to past browsers;
- defaults consistent with the target system.

## Consequences

### Positive

- the basic application behavior is reproducible;
- the new system already starts with sensible defaults;
- the more personal configurations remain modifiable.

### Negative

- some browser preferences will not be replicated 1:1;
- the import of extensions or Firefox profile remains outside the `v1`.

## For a student

Here the rule is simple:

- if a configuration is clear and portable, we version it;
- if an application has a better policy tool than the raw profile,
  we use that;
- if something is noisy or dull, we send it back.