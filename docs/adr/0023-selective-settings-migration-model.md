# ADR 0023 - Selective configuration migration model

## State

Accepted

## Context

The project now has an installed base mature enough to be able to bring in
`Margine` also configurations created on the real machine.

Here a classic risk arises:

- copy the entire home page;
- copy `/etc` by inertia;
- Transfer state, cache, desktop generated files, browser profiles or files
  temporary as if they were configuration.

This approach is the opposite of what we want.

## Decision

`Margine` adopts a selective migration model based on:

- explicit allowlist of approved `home` files;
- separate list of system configurations to review;
- versioning in the repo only of the files that make sense as baseline targets;
- explicit exclusion of opaque profiles, cache, volatile state and artifacts
  generated.

## Operational rules

### 1. Home

A home file or directory enters the project only if:

- it is readable and explainable;
- makes sense on a new installation;
- does not contain ephemeral state;
- does not depend on locally generated identifiers.

Esempi tipici:

- `~/.config/nvim`
- `~/.config/kitty/kitty.conf`
- `~/.config/mimeapps.list`
- `~/.config/user-dirs.*`
- small wrappers in `~/.local/bin`

### 2. System

Configurations outside the home are not automatically imported.

Instead, they are classified in a list of reviews:

- if they are still correct, they result in clean target files;
- if they are local workarounds or depend on the current system, they are rewritten;
- if they are noise, they are discarded.

### 3. Browsers and user profiles

Complete browser profiles do NOT go into the repo.

Reason:

- mix settings, cache, status, extensions, database and history;
- they are not very didactic;
- are fragile as a reproducible baseline.

For browsers we prefer:

- system policies;
- clear configuration files;
- explicit provisioning of basic choices.

### 4. Inventory

`Margine` keeps:

- an approved `home` allowlist;
- a `system` list to review;
- an inventory script that compares current machine and repo.

## Consequences

### Positive

- it avoids dragging rubbish into the new system;
- migration remains readable and didactic;
- app by app it becomes clear what we are really bringing.

### Negative

- more initial work is needed;
- some configurations are better reconstructed rather than copied;
- migration is never "all at once".

## For a student

Migrating well does not mean "backing up your home".
It means distinguishing:

- personal status;
- useful configuration;
- technical noise.

`Margine` carries only the second one.

