# Manifests

This directory contains the installable payload definitions for `Margine`.

Rules:

- keep manifests explicit and reviewable;
- do not dump `pacman -Qqe` blindly;
- treat each manifest as target-state intent, not as a machine snapshot.

## Shared baseline

The shared baseline lives in:

- `packages/*.txt`
- `flatpaks/apps.txt`

Those files describe the common `Margine` system.

## Flavor overlays

Flavor overlays can selectively replace individual manifests:

- `flavors/<name>/packages/<layer>.txt`
- `flavors/<name>/flatpaks/apps.txt`

If a flavor-specific file does not exist, the shared baseline is used.

Current flavor overlays:

- `arch`
- `cachyos`

## Product relationship

Products live one level above manifests, under `products/*.toml`.

A product chooses:

- the base distribution policy;
- the flavor overlay used for package resolution;
- the kernel / boot policy metadata;
- whether the product is public or private.

Today the public repository ships a single real product:

- `margine-public`
