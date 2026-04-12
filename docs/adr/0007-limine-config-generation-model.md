# ADR 0007 - Model generation of limine.conf

## State

Accepted

## Why this ADR exists

We already have:

- a strategy for `Limine`
- a versioned template of `limine.conf`
- a clear distinction between path `prod` and `recovery`

However, an operational rule was missing on an important point:

- Is the final `limine.conf` written by hand or generated?

## Problem to solve

The `limine.conf` file contains two very different types of information:

### Stable structure

- timeout
- branding
- entry `Produzione`
- entry `Fallback`
- diagram of the `Recovery` section

### Variable data

- `UUID` del root filesystem
- `UUID` of container `LUKS2`
- list of recovery entries and snapshots

If we treat the entire file the same way, we fall into one of two errors:

- or we keep it all by hand, and it becomes fragile;
- or we generate it all opaquely, and it stops being readable.

## Decision

For `Margine v1`, `limine.conf` will be a generated artifact.

Its logical source will be composed of:

1. template versioned in the repository;
2. machine facts passed to generator;
3. recovery block generated or provided separately.

## Fundamental rule

The final file on `ESP` is NOT the authoritative source.

The authoritative source is:

- the template in Git;
- plus machine data;
- plus the generated recovery block.

This means that:

- the final file can be regenerated;
- does not have to be hand-edited as the primary source;
- if it is edited manually, those changes are not considered stable.

## Initial operational choice

Let's introduce a small and readable script:

- `scripts/generate-limine-config`

Lo script deve:

- leggere il template;
- replace machine placeholders;
- optionally replace the recovery block between known markers;
- write the result to file or to `stdout`.

## Initial inputs required

For `v1`, the minimum generator inputs are:

- `ROOT_UUID`
- `LUKS_UUID`

Optional input:

- external file with recovery entries ready

## What the generator does NOT do in the first version

In the first version the generator DOES NOT:

- scans `Snapper` snapshots by itself;
- directly interrogate the installed system to discover every detail;
- modifies the `ESP` on your own;
- firma file;
- esegue `limine enroll-config`.

This limitation is intentional.

The first version must be:

- easy to read;
- easy to test;
- easy to compose with subsequent steps.

## Because this choice is healthy

Because it separates responsibilities well:

- template: struttura
- generatore: rendering
- future discovery layer: snapshot recovery
- futuro deploy layer: copia su `ESP`, enroll config, firma

In other words:

- first we build the pipeline;
- then we automate it in layers.

## Practical consequences

This choice allows us to do three useful things:

1. test the rendering without touching the real boot;
2. version the structure without freezing machine data;
3. add recovery generators later without rewriting everything.

## For a student: the simple version

If we explain it directly:

- the template is the mold;
- UUIDs and entry recoveries are the variable content;
- lo script mette insieme le due cose;
- the final file is not "the truth", it is the result of the process.
