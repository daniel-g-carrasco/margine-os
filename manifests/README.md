# Manifests

This directory contains the installable payload definitions for `Margine`.

Rules:

- keep manifests explicit and reviewable;
- do not dump `pacman -Qqe` blindly;
- treat each manifest as target-state intent, not as a machine snapshot.

## Shared baseline

The shared baseline lives in:

- `packages/*.txt`
- `aur/*.txt`
- `flatpaks/apps.txt`

Those files describe the common `Margine` system.

## Flavor overlays

Flavor overlays can selectively replace individual manifests:

- `flavors/<name>/packages/<layer>.txt`
- `flavors/<name>/aur/<layer>.txt`
- `flavors/<name>/flatpaks/apps.txt`

If a flavor-specific file does not exist, the shared baseline is used.

Current flavor overlays:

- `arch`
- `cachyos`

## Exploratory layers

Some layers are intentionally exploratory and must not be mistaken for part of
the default `Margine` baseline.

Today this includes:

- `aur/zfs-non-root-stack.txt`

That layer is meant for:

- non-root `ZFS` datasets
- local snapshot management with `sanoid`

It is explicitly **not** a `root-on-ZFS` install path.

## Product relationship

Products live one level above manifests, under `products/*.toml`.

A product chooses:

- the base distribution policy;
- the flavor overlay used for package resolution;
- the kernel / boot policy metadata;
- whether the product is public or private.

Today the public repository ships a single real product:

- `margine-public`
