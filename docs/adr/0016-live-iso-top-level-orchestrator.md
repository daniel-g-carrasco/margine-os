# ADR 0016 - Top-level orchestrator for installation from live ISO

## State

Accepted

## Why this ADR exists

With ADR 0014 and ADR 0015 we already have two correct pieces:

- `provision-storage`
- `bootstrap-live-iso`

However, a single entrypoint from live ISO that used them in sequence was missing.

## Problem to solve

If the user must always remember:

1. which script to call first;
2. which topics to replicate in the second;
3. how to go from partitioning to bootstrapping;

then the project remains correct but not very usable.

## Decision

For `Margine v1` we introduce a top-level script:

- `scripts/install-live-iso`

This script does not replace the two building blocks below.

Li orchestra.

## Design rule

The rule is:

- composition over separation;
- not monolith in place of separation.

So:

- `provision-storage` remains responsible for storage;
- `bootstrap-live-iso` remains responsible for phase 1 bootstrapping;
- `install-live-iso` calls them in the right order.

## Argument rule

The top-level script exposes:

- disk parameters;
- main storage parameters;
- ISO live bootstrap parameters;
- explicit destructive flag;
- `dry-run`.

Thus the user can work from just one command without losing readability.

## Scope rule

In `Margine v1`, `install-live-iso` does not yet do:

- end user bootstrap;
- enrollment `TPM2`;
- full trust chain signature;
- generation of the recovery block from real snapshots.

He does one specific thing:

- Merge storage provisioning and bootstrap phase 1 into a linear pipeline.

## Practical consequences

This choice gives us:

- a more human entrypoint from live ISO;
- true reuse of already separated scripts;
- better testability;
- less risk of introducing an unmanageable mega-script.

## For a student: the simple version

Think on three levels:

- single tools;
- una procedura;
- un comando che esegue la procedura.

`provision-storage` and `bootstrap-live-iso` are the individual tools.

`install-live-iso` is the command that uses them well.
