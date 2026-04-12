# ADR 0005 - UKI, Signing, and Limine Entry Strategy

## State

Accepted

## Why this ADR exists

Previous ADRs have set:

- the bootloader (`Limine`);
- the boot format (`UKI`);
- the trust chain (`Secure Boot`, `TPM2`);
- the storage layout (`LUKS2`, `Btrfs`, `Snapper`).

However, the most important operational part was missing:

- where the boot files live;
- how `UKI` are generated;
- what is signed;
- how normal boot and recovery are distinguished;
- how bootable snapshots fit with the `TPM2` policy.

## Problem to solve

There is a real technical tension:

- for daily booting we want a stable, simple and not very fragile chain;
- for snapshot-friendly recovery we want to be able to change the booted root
  explicitly.

With `systemd-stub`, if a `UKI` contains an embedded `.cmdline` and
`Secure Boot` is active, kernel command line overrides via bootloader
they are ignored.

This works well for normal booting, but makes snapshot-based recovery less
natural.

## Decision

For `Margine v1` we adopt a two-path strategy:

1. `prod` route, stable and TPM-friendly;
2. `recovery` path, flexible and snapshot-friendly.

This separation is intentional.
It's not redundancy: it's correct management of two different use cases.

## Product path

### Expected files

- `ESP/EFI/BOOT/BOOTX64.EFI` -> signed binary `Limine`
- `ESP/EFI/BOOT/limine.conf` -> main configuration
- `ESP/EFI/Linux/margine-linux.efi` -> `UKI` main signed
- `ESP/EFI/Linux/margine-linux-fallback.efi` -> `UKI` signed fallback

### Generation

Production `UKI` will be generated with `mkinitcpio`.

The production command line will be embedded in `UKI`, starting from:

- `/etc/kernel/cmdline`

### Reason

This gives us:

- repeatable boot;
- less ambiguity;
- a more readable `TPM2` chain;
- less dependency on parameters passed on the fly by the bootloader.

### Intended use

This path is intended for:

- daily boot;
- standard fallback kernel;
- stable validation of `TPM2`.

## Recovery path

### Expected files

- `ESP/EFI/Linux/margine-recovery.efi` -> `UKI` of signed recovery

### Generation

The recovery `UKI` will be built without a built-in command line.

The recovery `Limine` entries will then pass the command line at the time of
boot.

### Reason

This allows you to explicitly change:

- `rootflags=subvol=...`
- target snapshot
- any maintenance parameters

without having to regenerate a different `UKI` for each snapshot.

### Intended use

This path is designed for:

- `Snapper` snapshot boot;
- maintenance;
- reasoned recovery;
- emergency boot.

### Important safety rule

In the recovery path we do NOT assume convenient automatic unlocking via `TPM2` as a requirement.

Here the correct human path is:

- recovery key;
- or administrative passphrase.

This is acceptable, because recovery is not the optimized path for
minimal friction.
It is the optimized path to regain control.

## TPM2 strategy

The initial `TPM2` policy remains:

- `PCR 7+11`

but only for the `prod` path.

Reason:

- `PCR 7` links the unlocking to the `Secure Boot` state;
- `PCR 11` links the unlocking to the contents of the booted `UKI`.

We don't use `PCR 12` in the `prod` path, because we don't want to depend on an
external command line.

In the `recovery` path, where the command line comes from `Limine`, we accept
that booting may require human fallback.

## Secure Boot strategy

We adopt:

- proprietary keys managed with `sbctl`;
- signature of `UKI`;
- EFI binary signature of `Limine`.

Furthermore, following the official `Limine` documentation, the file
`limine.conf` will need to be bound to the EFI binary via:

- `limine enroll-config`

This is fundamental.

Signing only the EFI binary without protecting the configuration as well would
leave unprotected the file that decides:

- which entries exist;
- which paths are used;
- what boot parameters are passed.

## File placement

### Limine

`Limine` will be installed in the UEFI fallback location:

- `ESP/EFI/BOOT/BOOTX64.EFI`

The main configuration will live next to the binary:

- `ESP/EFI/BOOT/limine.conf`

This choice directly uses the behavior documented by `Limine`, which on UEFI
first looks for the config file next to the EFI executable.

### UKI

The `UKI` will live in:

- `ESP/EFI/Linux/`

Reason:

- clear and standardized path;
- separates the boot manager from the boot payloads;
- remains consistent with the modern `UKI` ecosystem.

## Logical structure of Limine entries

The `Limine` configuration will distinguish at least three groups:

- `Margine`
- `Fallback`
- `Recovery`

### Normal entries

Normal entries will use:

- `protocol: efi`
- `path: boot():/EFI/Linux/margine-linux.efi`

or:

- `path: boot():/EFI/Linux/margine-linux-fallback.efi`

### Recovery entries

Recovery entries will use:

- `protocol: efi`
- `path: boot():/EFI/Linux/margine-recovery.efi`
- `cmdline: ...`

with parameters targeted to the snapshot or maintenance context.

## Static config and generated parts

`limine.conf` will not have to be maintained entirely by hand.

We adopt this rule:

- header and entry base versioned in the repository;
- automatically generated recovery section.

In practice:

- part of the file is stable;
- some of it depends on the available snapshots.

This avoids two opposite errors:

- completely manual and fragile setup;
- completely opaque and unreadable configuration.

## Update pipeline pending

After each relevant boot path update, the pipeline should be:

1. pre-update snapshot
2. regenerate the normal `UKI`
3. regenerate the recovery `UKI`, if necessary
4. copy/refresh binary `Limine`
5. generation of `limine.conf`
6. `limine enroll-config`
7. sign with `sbctl`
8. verify signatures
9. post-update snapshot

## Practical consequences

This choice gives us a strong compromise:

- clean and stable normal boot;
- more flexible recovery;
- no obligation to generate a different `UKI` for each snapshot;
- `TPM2` concentrated where it actually makes sense;
- recovery remains possible even when the trust chain is not the most
  convenient one available.


## What we DON'T do in v1

Let's not do, for now:

- a different `UKI` for each snapshot;
- a design that demands `TPM2` seamless even in recovery;
- a dependency on `shim/MOK`;
- a `Limine` configuration edited only by hand directly on the `ESP`.

## For a student: the simple version

Put very simply:

- everyday booting must be stable;
- recovery must be flexible;
- it is not mandatory that they are the same technical path.

For that, we use:

- `UKI` with an embedded command line for normal boot;
- `UKI` more flexible recovery for snapshots and maintenance.

This is a real architectural decision:

- does not maximize theoretical purity;
- maximizes operational control.

## References

- `mkinitcpio(8)`:
  man locale
- `systemd-stub(7)`:
  man locale
- `systemd-cryptenroll(1)`:
  man locale
- `sbctl(8)`:
  https://man.archlinux.org/man/sbctl.8.en
- `Limine` `CONFIG.md`:
  https://raw.githubusercontent.com/limine-bootloader/limine/v11.x/CONFIG.md
- `Limine` `USAGE.md`:
  https://raw.githubusercontent.com/limine-bootloader/limine/v11.x/USAGE.md
- `Limine` `FAQ.md`:
  https://raw.githubusercontent.com/limine-bootloader/limine/v11.x/FAQ.md
- Arch package list file `limine`:
  https://archlinux.org/packages/extra/x86_64/limine/files/
