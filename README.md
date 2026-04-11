# Margine OS

`Margine` is a reproducible Linux desktop project built around:

- Arch-style rolling maintenance
- Hyprland as the primary desktop
- Framework Laptop 13 AMD as the reference hardware
- photography / media-friendly workstation defaults
- real rollback, boot recovery, and reinstallability

This repository is the **public and redistributable** side of the project.

## What this repository is

`Margine` is not a frozen distro fork.
It is a versioned system definition with:

- curated package manifests
- operational install and maintenance scripts
- versioned user and system configuration
- boot chain and recovery logic
- documentation for why each layer exists

The project starts from a readable repository, not from a monolithic custom ISO.

## Public vs private model

`Margine` now uses a product model:

- public repository: `margine-os`
- future private sister repository: `margine-os-personal`

The public repository contains:

- shared logic
- public documentation
- redistributable products
- flavor overlays that remain safe to publish

The private repository is expected to carry:

- private-only product manifests
- personal upstream integrations
- non-public experiments such as a true CachyOS-based personal build

See [products/README.md](products/README.md) and
[docs/03-products-and-repositories.md](docs/03-products-and-repositories.md).

## Core principles

- `Official repos first`: use AUR only when there is a clear reason.
- `Intent, not dump`: manifests describe the target system, not the current machine.
- `Readable operations`: scripts must stay understandable and auditable.
- `Rollback by design`: snapshots, recovery entries, and boot tooling are part of the architecture.
- `Hyprland-first`: the primary desktop path is Wayland / Hyprland.
- `Framework-aware`: hardware assumptions should stay explicit.
- `Public/private boundary`: public and personal products must not be mixed accidentally.

## Repository structure

- [`docs/`](docs): architecture notes, ADRs, roadmap, and status
- [`products/`](products): product manifests and templates
- [`manifests/`](manifests): shared package layers and flavor overlays
- [`scripts/`](scripts): installation, provisioning, validation, and update logic
- [`files/`](files): versioned files installed into `/etc`, `/usr`, and `$HOME`
- [`inventory/`](inventory): hardware notes and machine-specific observations

## Current public product

- [`margine-public`](products/margine-public.toml)

It currently targets:

- Arch as the public base
- `limine` as the bootloader
- `linux` as the default kernel package
- the shared `arch` flavor overlay

## Current project baseline

The public baseline already includes:

- `Limine + UKI + Btrfs + Snapper`
- staged recovery paths and boot artifact deployment
- reproducible install/bootstrap scripts
- versioned Hyprland desktop behavior
- explicit package, AUR, and Flatpak layers
- flavor-aware manifests
- product-aware scaffolding for future public/private split

Secure Boot bootstrap tooling is versioned, but still requires an explicit
post-install firmware-aware step.
TPM2 auto-unlock is part of the architectural direction, but is not yet
automated by the installer.

## Quick start

Prepare a QEMU validation VM:

```bash
./scripts/prepare-qemu-archiso-validation --product margine-public --download-iso
```

Run a real live-ISO install flow:

```bash
./scripts/install-live-iso-guided --product margine-public
```

Apply updates on an installed system:

```bash
update-all
```

Post-install validation checklist:

- [docs/05-post-install-validation.md](docs/05-post-install-validation.md)
- [docs/06-host-sync-workflow.md](docs/06-host-sync-workflow.md)
- [docs/07-snapshot-recovery-behavior.md](docs/07-snapshot-recovery-behavior.md)
- [docs/08-permanent-rollback-from-snapshot.md](docs/08-permanent-rollback-from-snapshot.md)
- [docs/09-installation-guide.md](docs/09-installation-guide.md)

## Current direction

Near-term work:

1. formalize the public/private repository split cleanly
2. keep the public product redistributable and well documented
3. continue validating recovery, boot, and reinstall paths
4. evolve future private products without contaminating the public repo
