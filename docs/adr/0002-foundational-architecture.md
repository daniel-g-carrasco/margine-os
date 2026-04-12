# ADR 0002 - Founding architecture of Margine

## State

Accepted

## Why this ADR exists

This is the first truly structural ADR.
It serves to decide the foundations that influence almost everything else:

- how the system starts;
- how it is protected;
- how to unlock the disk;
- how the data is organised;
- how to do snapshots and rollbacks.

If we make mistakes here, we bring with us friction and fragility at all stages
subsequent ones.

## Project requirements

The architectural basis must be:

- compatible with `Arch Linux`;
- consistent with `Framework Laptop 13 AMD`;
- suitable for `Hyprland` as the main environment;
- oriented towards stability and maintenance;
- confident, but not unnecessarily baroque;
- simple enough to be understood and modified by hand by Daniel;
- very strong in terms of recovery.

## Problem to solve

There are two main tensions:

1. we want a modern and clean base (`UKI`, `Secure Boot`, `TPM2`, `LUKS2`);
2. we also want a very simple recovery to use, especially via
   bootable snapshots.

Previously we had given more weight to architectural cleanliness.
After clarification of the requirements, it turned out that the simplicity of recovery is not
a quirk: it is a real requirement of the project.

## Options considered

### Option A

`systemd-boot` + `UKI` + `sbctl` + `TPM2` + `LUKS2` + `Btrfs` + `Snapper`

Advantages:

- it is the cleanest and most modern solution for Arch;
- integrates very well with `Secure Boot`;
- integrates very well with `TPM2` via `systemd-cryptenroll`;
- reduces the complexity of the boot chain;
- is very suitable for a personal system maintained with discipline.

Disadvantages:

- rollback from boot menu is not immediate;
- requires more procedural recovery;
- does not enhance the requirement expressed by Daniel: easy bootable snapshots
  use.

### Option B

`Limine` + `UKI` + `Snapper` + `LUKS2` + `TPM2` + `Btrfs`

Advantages:

- greatly improves the UX of recovery;
- lends itself well to bootable snapshots, in line with the model adopted by
  Omarchy;
- makes it more natural to test and restore snapshots from boot;
- better responds to the "simple and concrete recovery" requirement.

Disadvantages:

- requires more validation on the `Secure Boot` front;
- requires more attention in the design of the trust chain;
- is less linear than the `systemd-boot` road if the only criterion were the
  boot stack cleanup.

### Option C

`GRUB` + `Snapper` + `grub-btrfs`

Advantages:

- rollback from known and proven boot menu;
- very popular ecosystem when it comes to bootable snapshots.

Disadvantages:

- it is not the architectural direction that we want to favor;
- heavier boot chain;
- less coherence with the aim of keeping the project modern and readable.

## Decision

For `Margine v1` we adopt:

- `UEFI` pure;
- `Limine` as bootloader and main boot manager;
- `UKI` as standard boot format;
- `LUKS2` for disk encryption;
- `TPM2` through `systemd-cryptenroll`, with explicit human fallback;
- `Btrfs` as main filesystem;
- `Snapper` as base engine for snapshots and rollbacks;
- `Secure Boot` as an explicit objective of `v1`, but only after validation
  strict chain with `Limine`.

## Important clarification

This decision does NOT say:

- "Limine is an improved version of `systemd-boot`";
- "systemd-boot is wrong";
- "architectural cleanliness no longer matters".

Dice invece:

- `Limine` and `systemd-boot` are two distinct bootloaders, with different priorities;
- for this project, now, simple recovery weighs more than minimization
  boot stack absolute;
- the choice of `Limine` is accepted only together with a serious validation plan
  for `Secure Boot`, `UKI` and `TPM2`.

## Why Limine in this v1

The central reason is simple:

- Daniel considers simple recovery a very important feature;
- `Limine` makes a more natural experience with bootable snapshots;
- Omarchy uses this very direction to unlock a very recovery UX
  strong.

So, for `Margine`, `Limine` doesn't come in as an aesthetic quirk.
It comes in as a response to a real operational requirement.

## Validation conditions

The choice is considered successful only if we verify all these points:

1. `Limine` starts `UKI` reliably signed.
2. `Secure Boot` remains effectively under our control.
3. `TPM2` with `LUKS2` has a clean and documented recovery path.
4. `Snapper` snapshots are truly bootable and restoreable
   coherent.

If one of these four points fails structurally, fallback
architecture will be:

- `systemd-boot`
- `UKI`
- `sbctl`
- `LUKS2`
- `TPM2`
- `Btrfs`
- `Snapper`

So the decision is strong, but not blind.

## Implementation note

The architectural direction remains:

- `Secure Boot`
- `LUKS2`
- `TPM2`

But proper rollout is not monolithic.

The correct operating sequence is:

1. basic installation with `LUKS2`
2. boot and desktop validation
3. bootstrap `Secure Boot`
4. only then, enroll `TPM2` on the normal boot path

This point is important because an enrollment `TPM2` done before the
stabilization of `Secure Boot` or the final `UKI` risks binding to PCR
wrong and therefore breaking on the next reboot.

## Practical implications

### Boot

The boot chain will be designed like this:

1. UEFI firmware;
2. `Limine`;
3. `UKI`;
4. unlock disk with `LUKS2` and support `TPM2`;
5. root on `Btrfs`.

### Safety

Security should not depend on just one factor.

So we predict:

- unlock via `TPM2` as a convenient route;
- recovery key;
- emergency passphrase;
- clear recovery documentation.

### Snapshots

Snapshots will be designed as a central operational function, not as
accessory.

So:

- Btrfs layout designed for sensible snapshots;
- pre/post update hooks;
- bootable snapshots as an explicit target;
- documented restore procedure.

### Maintainability

This choice is less minimal than the `systemd-boot` road, but more in line with the
real requirements of `Margine`.

In other words:

- we lose a bit of theoretical linearity;
- we gain a stronger and more usable recovery.

## Decisions postponed

This ADR is NOT closing yet:

- exact partition scheme;
- exact scheme of Btrfs subvolumes;
- automatic snapshot operational policy;
- signature and hook details of the `Limine + UKI + Secure Boot` chain;
- PCR policy for `TPM2`.

These points will be addressed in subsequent ADRs.

Note:
- the final login path was then closed in subsequent ADRs with `greetd +
  tuigreet`, initial autologin and `hyprlock`.

## For a student: the simple version

If we explained it directly:

- `Limine` is the piece that gives us a more interesting recovery at boot;
- `UKI` is a modern and tidy boot format;
- `LUKS2` protects data on disk;
- `TPM2` can help you unlock the disk conveniently, but it does not replace the
recovery;
- `Btrfs` gives us snapshots and flexibility;
- `Snapper` helps us manage snapshots well;
- we are not choosing the most minimal path;
- we are choosing the path that most values ​​recovery, but without
  give up rigor and checks.

## References

- Omarchy, official issue on `Limine + Snapper`:
  https://github.com/basecamp/omarchy/issues/1068
- Limine, official repository:
  https://github.com/limine-bootloader/limine
- ArchWiki, panoramica bootloader:
  https://wiki.archlinux.org/title/Boot_loader
- ArchWiki, `Secure Boot`:
  https://wiki.archlinux.org/title/Secure_Boot
- ArchWiki, `systemd-cryptenroll`:
  https://wiki.archlinux.org/title/Systemd-cryptenroll
- ArchWiki, `Snapper`:
  https://wiki.archlinux.org/title/Snapper
