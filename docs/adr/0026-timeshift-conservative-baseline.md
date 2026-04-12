# ADR 0026 - Conservative Timeshift Baseline in Margin

## State

Accepted

## Context

`Margine` also installs `Timeshift`, but the project architecture is
built around:

- `Btrfs`
- `Snapper`
- `Limine`
- `UKI`

This means that `Timeshift` cannot be treated as an engine
main rollback without creating ambiguity.

Furthermore, there is an important constraint: the official documentation of `Timeshift`
indicates that Btrfs support is limited to Ubuntu-style layouts with soli
subvolumes `@` and `@home`.

`Margine` instead uses a richer layout, with additional dedicated subvolumes.

## Decision

For `Margine v1` we adopt a conservative baseline:

- `Timeshift` remains installed;
- a clean `default.json` is versioned without machine-specific UUIDs;
- `btrfs_mode` remains disabled in the defaults;
- automatic snapshots `Timeshift` remain disabled by default;
- the choice of backup device remains explicit and subsequent to installation.

## Motivation

### 1. Avoid officially unsupported configurations

We don't want to pre-configure `Timeshift` in a way that the documentation
official declares no support for Btrfs layouts other than `@/@home`.

### 2. Avoid double engine automatic rollback

If `Snapper` is the main engine for:

- system snapshot;
- recovery from update;
- entries bootable via `Limine`;

then `Timeshift` doesn't have to pretend to be the same thing.

### 3. Keep Timeshift as a companion tool

`Timeshift` can remain useful as a tool:

- manual;
- familiarity for the user;
- possibly oriented to `rsync` on separate target.

## Consequences

### Positive

- no UUIDs inherited from the source machine;
- no fragile or misleading preconfiguration;
- clear consistency: `Snapper` first, `Timeshift` as extra.

### Negative

- `Timeshift` does not start immediately as an automatic snapshot system;
- the user will then have to choose the backup device if he wants to use it.

## For a student

Here the teaching point is important:

- installing a package doesn't mean you have to make it the centerpiece of the
  project;
- if a tool has structural limits compared to your architecture, that's better
  use it prudently than force it.

