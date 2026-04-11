# ADR 0038 - Installed Update Runtime And Host Delegating Wrapper

## Status

Accepted

## Context

The project hit a real drift problem:

- the host had an old `$HOME/.local/bin/update-all`
- the repository had newer logic
- the installed global runtime was not always the one being executed

That produced confusing failures and made debugging much harder than it should
have been.

## Decision

`Margine` treats the installed update runtime as a first-class part of the
product.

The canonical execution model is:

- shared runtime under `/usr/local/lib/margine`
- global launcher at `/usr/local/bin/update-all`
- optional user-level wrapper at `$HOME/.local/bin/update-all` that delegates to
  the installed global runtime

The user-level wrapper must not carry an independent maintenance implementation.

## Why

The failure mode we want to prevent is simple:

- the user runs `update-all`
- `PATH` resolves an obsolete local copy
- the system behaves differently from the current repository and installed
  product state

Delegation makes the execution path explicit and reduces shadowing bugs.

## Consequences

### Positive

- host/runtime drift becomes easier to detect
- the installed system has a single canonical maintenance implementation
- per-user convenience remains possible without duplicating logic

### Negative

- provisioning must install both the runtime and the launcher correctly
- broken or missing global runtime is now surfaced immediately by the wrapper

## Operational rule

If host behavior differs from repository expectations, the first checks should
be:

1. `command -v update-all`
2. whether `/usr/local/bin/update-all` exists
3. whether `/usr/local/lib/margine` matches the current provisioned state
