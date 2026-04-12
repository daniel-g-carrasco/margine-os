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

If we get this wrong, we carry friction and fragility into every later stage.

## Project requirements

The architectural basis must be:

- compatible with `Arch Linux`;
- consistent with `Framework Laptop 13 AMD`;
- suitable for `Hyprland` as the main environment;
- oriented towards stability and maintenance;
- confident, but not unnecessarily baroque;
- simple enough to be understood and modified by hand by Daniel;
- very strong from a recovery perspective.

## Problem to solve

There are two main tensions:

1. we want a modern and clean base (`UKI`, `Secure Boot`, `TPM2`, `LUKS2`);
2. we also want a very simple recovery to use, especially via
   bootable snapshots.

Previously we had given more weight to architectural cleanliness.
After clarifying the requirements, it became clear that recovery simplicity is
not a nice-to-have. It is a real project requirement.

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
- does not serve Daniel's explicit requirement: easy-to-use bootable
  snapshots.

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

- pure `UEFI`;
- `Limine` as bootloader and main boot manager;
- `UKI` as standard boot format;
- `LUKS2` for disk encryption;
- `TPM2` through `systemd-cryptenroll`, with explicit human fallback;
- `Btrfs` as main filesystem;
- `Snapper` as the base engine for snapshots and rollbacks;
- `Secure Boot` as an explicit `v1` objective, but only after strict
  validation of the chain with `Limine`.

## Important clarification

This decision does NOT say:

- "Limine is an improved version of `systemd-boot`";
- "systemd-boot is wrong";
- "architectural cleanliness no longer matters".

It does say:

- `Limine` and `systemd-boot` are two distinct bootloaders, with different priorities;
- for this project, right now, simple recovery matters more than absolute boot
  stack minimization;
- the choice of `Limine` is accepted only together with a serious validation plan
  for `Secure Boot`, `UKI` and `TPM2`.

## Why Limine in this v1

The central reason is simple:

- Daniel considers simple recovery a very important feature;
- `Limine` makes a more natural experience with bootable snapshots;
- Omarchy uses this same direction to achieve a very strong recovery UX.

So, for `Margine`, `Limine` doesn't come in as an aesthetic quirk.
It comes in as a response to a real operational requirement.

## Validation conditions

The choice is considered successful only if we verify all these points:

1. `Limine` starts `UKI` reliably signed.
2. `Secure Boot` remains effectively under our control.
3. `TPM2` with `LUKS2` has a clean and documented recovery path.
4. `Snapper` snapshots are genuinely bootable and can be restored coherently.

If one of these four points fails in a structural way, the fallback
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

This matters because a `TPM2` enrollment done before `Secure Boot` and the
final `UKI` are stable risks binding to the wrong PCR values and then breaking
on the next reboot.

## Practical implications

### Boot

The boot chain will be designed like this:

1. UEFI firmware;
2. `Limine`;
3. `UKI`;
4. disk unlock with `LUKS2` and `TPM2` support;
5. root on `Btrfs`.

### Safety

Security should not depend on just one factor.

So we predict:

- unlock via `TPM2` as a convenient route;
- recovery key;
- emergency passphrase;
- clear recovery documentation.

### Snapshots

Snapshots will be designed as a central operational function, not as an
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
- we are choosing the path that values recovery the most, without giving up
  rigor and validation.

## References

- Omarchy, official issue on `Limine + Snapper`:
  https://github.com/basecamp/omarchy/issues/1068
- Limine, official repository:
  https://github.com/limine-bootloader/limine
- ArchWiki, boot loader overview:
  https://wiki.archlinux.org/title/Boot_loader
- ArchWiki, `Secure Boot`:
  https://wiki.archlinux.org/title/Secure_Boot
- ArchWiki, `systemd-cryptenroll`:
  https://wiki.archlinux.org/title/Systemd-cryptenroll
- ArchWiki, `Snapper`:
  https://wiki.archlinux.org/title/Snapper
