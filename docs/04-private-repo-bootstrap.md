# Private Repository Bootstrap

This document describes the intended setup for the future private sister
repository.

## Goal

Keep:

- `margine-os` as the public upstream
- `margine-os-personal` as the private downstream

## Recommended Git remote layout

In the private repository:

- `origin` -> private repository
- `upstream` -> public repository

Example:

```bash
git remote add upstream https://github.com/daniel-g-carrasco/margine-os.git
git fetch upstream
```

## Initial bootstrap flow

1. create the private repository;
2. seed it from the public repository;
3. keep product-specific overlays and manifests there;
4. regularly merge or rebase from `upstream/main`.

## Minimum private additions

The private repository should add:

- `products/margine-cachyos.toml`
- private package layers such as `manifests/packages/cachyos-personal-extras.txt`
- private product-specific provisioners such as
  `scripts/provision-cachyos-personal-baseline`
- private product-specific documentation
- private rollout plans such as `docs/13-margine-cachyos-personal-import-plan.md`
- private manifest overrides if needed
- private release/build automation

It should not duplicate the full public repository structure unnecessarily.

## Example private product manifest

Start from:

- [`products/templates/margine-cachyos-private.toml.example`](../products/templates/margine-cachyos-private.toml.example)

Then promote it to:

- `products/margine-cachyos.toml`

inside the private repository.

If the private product needs product-specific installation extensions, use the
optional manifest fields:

- `extra_package_layers`
- `extra_provisioners`

and add the corresponding files only in the private repository.
